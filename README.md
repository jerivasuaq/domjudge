Using Domjudge docker containers
================================


Setup domjudge_web
-------------------

```
    ./setup_web
    ./setup_judgehost
```

Start DB
-------------------

```
    ./start_db.sh
```

Start Web
-------------------


```
    ./start_web.sh
```

Configure users
-------------------

Visit: 

[Users](http://localhost:49155/domjudge/jury/users.php)

Change judgehost password vist

[Judgehost Password](http://localhost:49155/domjudge/jury/user.php?cmd=edit&id=2&referrer=users.php)



Create a team user
-------------------

Visit 

[New Team User](http://localhost:49155/domjudge/jury/users.php)

Make sure the user is added to a team


Start a judgehost client
-------------------

### Configure restapi.secret

Edit the file judgehost/Dockerfile/restapi.secret

Using the same password as the Jusgehost user set before:

[Judgehost Password](http://localhost:49155/domjudge/jury/user.php?cmd=edit&id=2&referrer=users.php)

So it reads like this:

default http://domjudge_web/domjudge/api   judgehost   **CHAGE_PASSWORD**


```
    ./start_judgehost
```

Test solving a problem
-------------------

Login as a team user and submit a source code file 

[Solve a problem](http://localhost:49155/domjudge/team/index.php)





