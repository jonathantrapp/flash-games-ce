"""Local-only player for comparing the supplied SWFs with calculator ports."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import mimetypes

ROOT = Path(__file__).resolve().parent.parent
RUNTIME = ROOT / 'local-tools/ruffle-web/package'
SWFS = {'scoutcamp.swf': Path('C:/Users/jonat/Downloads/scoutcamp_unlocked.swf'),
        'pedrofu.swf': Path('C:/Users/jonat/Downloads/pedrofu_unlocked.swf')}
HTML = b'''<!doctype html><html><head><meta charset="utf-8"><title>Original Flash reference</title>
<style>body{margin:0;background:#181b24;color:#eee;font:16px sans-serif;text-align:center}nav{padding:12px}a{color:#9bd4ff;margin:20px}#player{width:640px;height:480px;margin:16px auto}ruffle-player{width:100%;height:100%}</style>
</head><body><nav><a href="/?game=scoutcamp">Scouts vs Aliens original</a><a href="/?game=pedrofu">Pedro Kicks Back original</a></nav><div id="player"></div>
<p>Original supplied SWF, running locally in Ruffle for comparison.</p><script src="/ruffle/ruffle.js"></script>
<script>window.RufflePlayer.config={autoplay:"on",unmuteOverlay:"hidden",allowScriptAccess:false};
const game=new URLSearchParams(location.search).get("game")==="pedrofu"?"pedrofu":"scoutcamp";
const player=window.RufflePlayer.newest().createPlayer();document.getElementById("player").appendChild(player);player.ruffle().load({url:"/"+game+".swf",allowScriptAccess:false});</script></body></html>'''

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        route = self.path.split('?', 1)[0]
        if route == '/':
            data, mime = HTML, 'text/html; charset=utf-8'
        else:
            path = SWFS.get(route.lstrip('/'))
            if route.startswith('/ruffle/'):
                candidate = (RUNTIME / route.removeprefix('/ruffle/')).resolve()
                if candidate.parent == RUNTIME.resolve():
                    path = candidate
            if path is None or not path.is_file():
                self.send_error(404)
                return
            data = path.read_bytes()
            mime = 'application/wasm' if path.suffix == '.wasm' else mimetypes.guess_type(str(path))[0] or 'application/octet-stream'
        self.send_response(200)
        self.send_header('Content-Type', mime)
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

if __name__ == '__main__':
    print('Original game reference: http://127.0.0.1:8769', flush=True)
    ThreadingHTTPServer(('127.0.0.1', 8769), Handler).serve_forever()
