# save as linear_oauth_listener.py
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse

class OAuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        query = urllib.parse.parse_qs(parsed.query)
        code = query.get("code", [""])[0]

        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(f"<html><body><h1>Code received:</h1><p>{code}</p></body></html>".encode())

        print(f"\n🔑 OAuth code: {code}\n")

server = HTTPServer(("127.0.0.1", 8787), OAuthHandler)
print("🔌 Listening on http://127.0.0.1:8787/callback")
server.serve_forever()
