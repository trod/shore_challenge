# ShoreChallenge

## Disclaimer:
I have never played ten-pin bowling, so there can be a slight difference in the actual and implemented game rules.

The way it is implemented:
```
Normal Frame: Score = Roll 1  + Roll 2
Spare Frame: Score = Roll 1 + Roll 2 + Spare bonus
Strike Frame: Score = Roll 1 + Strike bonus 1 + Strike bonus 2
```

## Comments:
In this challenge I decided to try something new and implemented a simple in-memory ets storage for bowling games. Every game runs in its own process and completely isolated from others. Biggest and natural disadvantage of that approach is that all the games are lost in case of server restart/crash.
Below you can find my notes which I made during the development. Also I want to list some parts I would like to add or improve if I'd have more time:

- Proper error templating.
- Switch to json request/response as it's more flexible than plain params.
- Add proper API documentation: https://swagger.io/tools/swagger-ui/ is just great.
- Add telemetry: https://www.jaegertracing.io/
- Add authentication.
- I'd like to completely refactor controller (see todos in there).
- Better logging.
- Implement persistent storage and use ets as a cache
- Run more tests.
- Specs! (completely forgot to add them)

## Notes during developement:
- ~scaffold project~
- ~implement core logic~
- ~db and ecto stuff~ Note: removed in favor of in-memory ets storage
- ~write unit tests~
- add specs
- ~implement API~
- ~better error handling for API~
- ~write api tests~
- ~documentation~ (maybe use swagger?)
- ~clean-up~

## Installation
  * Install dependencies with `mix deps.get`
  * Start API endpoints with `mix phx.server`
  
## Tests
 Run tests with `mix test`

## API:
```mix phx.routes
bowling_path  POST  /api/new           ShoreChallengeWeb.BowlingController :new
bowling_path  GET   /api/score         ShoreChallengeWeb.BowlingController :score
bowling_path  POST  /api/roll          ShoreChallengeWeb.BowlingController :roll
```
### Usage example:
#### Create new game:
```
curl -X POST http://localhost:4000/api/new
6fb4528e-419d-420c-98c4-f1b900f7320b
```
#### Get score:
```
curl -X GET "http://localhost:4000/api/score?game_id=6fb4528e-419d-420c-98c4-f1b900f7320b"
0
```
### Add roll:
```
curl -X POST "http://localhost:4000/api/roll?game_id=6fb4528e-419d-420c-98c4-f1b900f7320b&score=10"
10
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
