from flask import Flask

import src.database as database
import dbg

_server: 'Server' = None

class Server:
    def __init__(self, host='localhost', port=5000):
        self.host = host
        self.port = port
        self.app = Flask(__name__)
        


    @staticmethod
    def init(host='localhost', port=5000):
        global _server
        if _server is None:
            _server = Server(host, port)
        return _server

    @staticmethod
    def instance():
        global _server
        if _server is None:
            raise RuntimeError("Server not initialized. Call Server.init() first.")
        return _server

    @staticmethod
    def run():
        from routes.residue_router import prq
        
        global _server
        if _server is None:
            raise RuntimeError("Server not initialized. Call Server.init() first.")
        dbg.log_info("Starting _server...")

        # Registra as rotas
        _server.app.register_blueprint(prq, url_prefix='/')

        dbg.log_info(f"Server running on {_server.host}:{_server.port}")
        _server.app.run(host=_server.host, port=_server.port, debug=True)
