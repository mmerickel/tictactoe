import logging
import uuid

from pyramid.response import Response
from pyramid.view import view_config

from model import Client, TicTacToe
from model import clients, client_names, unique_client_num
from model import pending_games, games

log = logging.getLogger(__name__)

RESUME_ERROR = {'error': {'code': 110, 'message': 'cannot resume game'}}
INVALID_CLIENT_ID = {'error': {'code': 101, 'message': 'invalid client id'}}
INVALID_CLIENT_NAME = {'error': {'code': 104, 'message': 'invalid client name'}}
INVALID_GAME_ID = {'error': {'code': 102, 'message': 'invalid game id'}}
INVALID_MOVE = {'error': {'code': 103, 'message': 'invalid move'}}

def create_client_id():
    return uuid.uuid4().hex

def create_game_id():
    return uuid.uuid4().hex[:8]

def create_name():
    return 'Guest%04d' % (1000 + unique_client_num)

@view_config(route_name='api.play', request_method='POST', renderer='json')
def play_view(request):
    client_id = request.POST.get('client_id')
    name = request.POST.get('name')
    resume = request.POST.get('resume', False)

    client = clients.get(client_id)
    if resume:
        return RESUME_ERROR
#        if client:
#            # preserve previous name if we are resuming a game
#            name = client.name
#
#            game = games.get(client.game_id)
#            if game is None or game.complete():
#                return RESUME_ERROR
#        else:
#            return RESUME_ERROR

    # initialize the client
    if client:
        # log the client out, killing their current games
        quit_view(request)
        if name:
            client.name = name
    else:
        client_id = client_id or create_client_id()
        name = name or create_name()
        client = Client(client_id, name)

        # new client, increase unique count
        global unique_client_num
        unique_client_num += 1

    # avoid multiple clients with the same name
    if name in client_names:
        return INVALID_CLIENT_NAME

    # add the client to a game and possibly begin
    if len(pending_games) > 0:
        game = pending_games.popleft()
        game.add_player(client)
        if game.is_ready():
            game.begin()
        else:
            pending_games.appendleft()
    else:
        game_id = create_game_id()
        game = TicTacToe(game_id)
        game.add_player(client)

        pending_games.append(game)
        games[game_id] = game

    # remember the client
    client.game_id = game.id
    clients[client.id] = client
    client_names.add(client.name)

    return {
        'client_id': client.id,
        'name': client.name,
        'game_id': client.game_id,
    }

@view_config(route_name='api.quit', request_method='POST', renderer='json')
def quit_view(request):
    client_id = request.POST.get('client_id')
    client = clients.get(client_id)
    if client is None:
        return INVALID_CLIENT_ID

    game = games[client.game_id]
    game.remove_player(client)
    game.end('%s quit the game' % client.name)

    client_names.remove(client.name)
    del clients[client_id]
    return {}

@view_config(route_name='api.move', request_method='POST', renderer='json')
def move_view(request):
    client_id = request.POST.get('client_id')
    position = int(request.POST['position'])

    client = clients.get(client_id)
    if client is None:
        return INVALID_CLIENT_ID

    game = games[client.game_id]
    if not game.check_move(client, position):
        return INVALID_MOVE
    game.move(position)

    return {
    }

@view_config(route_name='api.chat', request_method='POST', renderer='json')
def chat_view(request):
    client_id = request.POST.get('client_id')
    message = request.POST.get('message')

    client = clients.get(client_id)
    if client is None:
        return INVALID_CLIENT_ID

    game = games[client.game_id]
    game.chat(client, message)

    return {
    }

@view_config(route_name='api.updates', request_method='GET', renderer='json')
def updates_view(request):
    game_id = request.matchdict['gameid']
    cursor = int(request.GET.get('cursor', 0))

    game = games[game_id]
    r = Response()
    #r.content_encoding = 'chunked'
    r.app_iter = game.add_observer(cursor)
    return r
