You are assisting in debugging a Laravel 8+ web app deployed on a CentOS/AlmaLinux VPS running Nginx + PHP-FPM 8.2.
### Summary

1. App: Laravel 8, Nginx, PHP 8.2, root path /var/www/tagxi/.../Admin-Panel-Aug-20-2025  
2. Domain: admin.hayyaride.com (SSL OK, session.domain=admin.hayyaride.com)  
3. Issue: /login → 500 error; /dashboard → 302 → /login  
4. Cause: LoginController extends ApiController, no showLoginForm() method  
5. Goal: make /login render Blade view and /dashboard require auth  
6. SSH: ssh root@159.198.36.105 (pwd: GC16r3poLhU0RV16tc)  
7. cd /var/www/tagxi/appsrc/Main-File-August-20/Admin-Panel-Aug-20-2025  
8. Check log after visiting /login → tail -n 100 storage/logs/laravel.log  
9. Inspect LoginController for available methods (index, viewLogin, etc.)  
10. If no view method exists, add: return view('web.auth.login');  
11. Update routes/web.php → GET /login points to correct method  
12. Verify Blade view exists under resources/views/web/auth/login.blade.php  
13. Remove or guard all auth('web')->login($user, true) in controllers  
14. Clear caches → php artisan optimize:clear && route:cache  
15. Test again → curl -k -I https://admin.hayyaride.com/login  
16. /login should return 200 OK (no remember_web cookie)  
17. /dashboard should 302 to /login when logged out  
18. After login, redirect → /dashboard  
19. Keep session.domain admin.hayyaride.com (don’t share with main site)  
20. Done when route:cache works, login page loads, and auto-login removed

