from collections import deque
from datetime import datetime
from random import shuffle

import gevent
from gevent.event import Event
from gevent.queue import Queue

from pyramid.compat import json

unique_client_num = 0
clients = {}
client_names = set()
pending_games = deque()
games = {}

class Client(object):
    def __init__(self, id, name, game=None):
        self.id = id
        self.name = name
        self.game = game

class Observer(Queue):
    def __init__(self, *args, **kw):
        game = kw.pop('game')
        self.event = Event()
        Queue.__init__(self, *args, **kw)
        def reaper():
            self.event.clear()
            self.event.wait(30)
            game.remove_observer(self)
        gevent.spawn(reaper)

    def get(self, *args, **kw):
        self.event.set()
        return Queue.get(self, *args, **kw)

class Game(object):
    Observer = Observer # testing hook

    def __init__(self, id):
        self.id = id
        self.players = []
        self.observers = []
        self.updates = [None] # offset since actual cursor starts at 1
        self.cursor = 0

    def is_ready(self):
        return False

    def is_complete(self):
        return False

    def add_player(self, client):
        self.players.append(client)
        self.add_update(
            type='connect',
            name=client.name,
            player=True,
        )

    def remove_player(self, client):
        self.add_update(
            type='disconnect',
            name=client.name,
            player=True,
        )

    def chat(self, client, message):
        self.add_update(
            type='chat',
            name=client.name,
            message=message,
        )

    def add_update(self, **kw):
        self.cursor += 1
        kw.setdefault('timestamp', datetime.utcnow().isoformat())
        kw.setdefault('cursor', self.cursor)
        self.updates.append(kw)
        self.notify_observers(kw)

    def add_observer(self, cursor=None):
        obs = self.Observer(game=self)
        if cursor == self.cursor or cursor is None:
            self.observers.append(obs)
        else:
            msg = json.dumps(self.updates[cursor+1])
            obs.put(msg)
            obs.put(StopIteration)
        return obs

    def remove_observer(self, obs):
        if obs in self.observers:
            obs.put(StopIteration)
            i = self.observers.index(obs)
            del self.observers[i]

    def notify_observers(self, msg):
        out = json.dumps(msg)
        for obs in self.observers:
            obs.put(out)
            obs.put(StopIteration)
        # for now just kill observers once a message is sent instead
        # of playing with chunked encoding
        self.observers = []

class TicTacToe(Game):
    def begin(self):
        self.board = list('_________')
        self.turn = 'X'
        self.winner = None

        shuffle(self.players)
        self.playerX, self.playerO = self.players

        self.add_update(
            type='status',
            board=''.join(self.board),
            turn=self.turn,
            playerX=self.playerX.name,
            playerO=self.playerO.name,
        )

    def end(self, reason):
        self.add_update(
            type='end',
            reason=reason,
        )
        if self in pending_games:
            pending_games.remove(self)
        def cleanup():
            for p in self.players:
                if p.game is self:
                    p.game = None
            del games[self.id]
        gevent.spawn_later(86400, cleanup) # cleanup in a day

    def is_ready(self):
        return len(self.players) == 2

    def is_complete(self):
        return self.winner is not None

    def check_move(self, client, position):
        if self.is_complete(): return False
        if self.turn == 'X' and client != self.playerX: return False
        if self.turn == 'O' and client != self.playerO: return False
        if self.board[position] != '_': return False
        return True

    def move(self, position):
        turn = self.turn
        self.board[position] = turn
        if self._check_winner():
            result = {'winner': self.turn}
            self.winner = self.turn
        else:
            self.turn = 'O' if self.turn == 'X' else 'X'
            result = {'turn': self.turn}
        self.add_update(
            type='move',
            board=''.join(self.board),
            player=turn,
            position=position,
            **result
        )

        if self.winner:
            self.end('player %s won' % self.winner)

    def _check_winner(self):
        b = self.board
        # check horizontal
        for i in range(3):
            if '_' != b[3*i] == b[3*i+1] == b[3*i+2]:
                return True
        # check vertical
        for i in range(3):
            if '_' != b[i] == b[3+i] == b[6+i]: return True
        # check diagonals
        if '_' != b[0] == b[4] == b[8]: return True
        if '_' != b[2] == b[4] == b[6]: return True
        return False

