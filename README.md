# Smoke 

Solution for the Smoke Test from [Protohacker](https://protohackers.com/problem/0) using `:gen_tcp`.

## Testing

```
mix test
```

## Running locally with mix
```
mix run --no-halt
```

## Running locally with Docker
```
PORT=5000 # or any port you want
docker build -t protohackers/smoke .
docker run -e PORT=$PORT protohackers/smoke
```

## Running with existing Docker image
```
PORT=5000 # or any port you want
docker run -e PORT=$PORT purplealchemist/smoke
```