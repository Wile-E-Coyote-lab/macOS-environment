# cli/oauth/listener.py
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse, os

class OAuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        query = urllib.parse.urlparse(self.path).query
        code = urllib.parse.parse_qs(query).get('code', [''])[0]
        if code:
            print(f"🔑 OAuth code received: {code}")
            with open(".linear/oauth_code", "w") as f:
                f.write(code)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"OAuth code received. You may close this window.")

HTTPServer(('127.0.0.1', 8787), OAuthHandler).serve_forever()
