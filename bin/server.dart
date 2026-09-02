import 'dart:io';
import 'package:path/path.dart' as p;

/// A simple static file server that redirects unknown routes to index.html (SPA Fallback)
void main() async {
  final port = 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print(
      'SPA Server running on http://localhost:$port (Accessible via your local IP address)');

  await for (HttpRequest request in server) {
    final uri = request.uri;
    String path = uri.path;

    if (path == '/') path = '/index.html';
    if (path == '/admin') path = '/admin.html';

    if (path.contains('..')) {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..close();
      continue;
    }

    // Attempt to serve the file
    File file = File('.$path');

    if (await file.exists()) {
      await serveFile(file, request);
    } else {
      // SPA Fallback: If the file doesn't exist, serve index.html
      // This is crucial for routes like /services, /news, etc.
      File indexFile = File('./index.html');
      if (await indexFile.exists()) {
        await serveFile(indexFile, request);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('404 Not Found')
          ..close();
      }
    }
  }
}

Future<void> serveFile(File file, HttpRequest request) async {
  final ext = p.extension(file.path).toLowerCase();
  String contentType = 'text/plain';

  switch (ext) {
    case '.html':
      contentType = 'text/html; charset=utf-8';
      break;
    case '.css':
      contentType = 'text/css';
      break;
    case '.js':
      contentType = 'application/javascript';
      break;
    case '.png':
      contentType = 'image/png';
      break;
    case '.jpg':
    case '.jpeg':
      contentType = 'image/jpeg';
      break;
    case '.svg':
      contentType = 'image/svg+xml';
      break;
    case '.json':
      contentType = 'application/json';
      break;
    case '.dart':
      contentType = 'application/dart';
      break;
  }

  request.response.headers.contentType = ContentType.parse(contentType);
  request.response.headers.add('Cache-Control', 'no-cache, no-store, must-revalidate');

  try {
    await request.response.addStream(file.openRead());
  } catch (e) {
    request.response.statusCode = HttpStatus.internalServerError;
  } finally {
    await request.response.close();
  }
}
