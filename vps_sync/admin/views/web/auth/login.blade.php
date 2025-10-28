<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Admin Login</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
  <style>
    body { font-family: Inter, system-ui, -apple-system, Segoe UI, Roboto, sans-serif; background:#f6f7f9; margin:0; display:flex; min-height:100vh; align-items:center; justify-content:center; }
    .card { background:#fff; width:100%; max-width:380px; padding:28px; border-radius:12px; box-shadow:0 6px 24px rgba(0,0,0,.08); }
    h1 { font-size:22px; margin:0 0 18px; }
    .field { margin-bottom:14px; }
    label { display:block; font-size:12px; color:#444; margin-bottom:6px; }
    input { width:100%; padding:11px 12px; border:1px solid #d3d8e0; border-radius:8px; font-size:14px; }
    button { width:100%; padding:12px; background:#111827; color:#fff; border:0; border-radius:8px; font-weight:600; cursor:pointer; }
    .error { color:#b91c1c; font-size:13px; margin:6px 0 0; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Admin Login</h1>
    @if ($errors->any())
      <div class="error">{{ $errors->first() }}</div>
    @endif
    <form method="POST" action="{{ route('login.attempt') }}">
      @csrf
      <div class="field">
        <label for="email">Email</label>
        <input id="email" name="email" type="email" value="{{ old('email') }}" required autofocus />
      </div>
      <div class="field">
        <label for="password">Password</label>
        <input id="password" name="password" type="password" required />
      </div>
      <div class="field" style="display:flex;align-items:center;gap:8px">
        <input id="remember" name="remember" type="checkbox" value="1" />
        <label for="remember" style="margin:0">Remember me</label>
      </div>
      <button type="submit">Sign in</button>
    </form>
  </div>
</body>
</html>
