import argparse

from app import make_app

def serve_gevent(app, host, port):
    import gevent.monkey; gevent.monkey.patch_all()
    import gevent.pywsgi

    server = gevent.pywsgi.WSGIServer((host, port), app)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.kill()

def serve_mongrel2(app, send_socket, recv_socket):
    from m2wsgi.io.gevent import WSGIHandler, Connection

    conn = Connection(send_sock=send_socket, recv_sock=recv_socket)
    handler = WSGIHandler(app, conn)
    handler.serve()

def main(*args):
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='cmd')

    m2_parser = sub.add_parser('mongrel2')
    m2_parser.add_argument('--send')
    m2_parser.add_argument('--recv')

    gevent_parser = sub.add_parser('gevent')
    gevent_parser.add_argument('--host', default='0.0.0.0')
    gevent_parser.add_argument('-p', '--port', type=int, default=8080)

    opts = parser.parse_args(args)

    settings = {}
    app = make_app({}, **settings)

    if opts.cmd == 'gevent':
        serve_gevent(app, opts.host, opts.port)
    elif opts.cmd == 'mongrel2':
        serve_mongrel2(app, opts.send, opts.recv)

if __name__ == '__main__':
    import sys
    main(*sys.argv[1:])
