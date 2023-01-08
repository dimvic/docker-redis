# redis with self-signed certificate and ACL

Insecure mode is required for clients to access redis instances using self-signed certificates.

There is nothing insecure about using self-signed certificates other than that the certificate is not automatically
trusted by the client.

Self-signed certificates are generated on build.
ACL configuration loaded from `conf/redis.acl` (see `conf/redis.acl.example`).

See `conf/*`, `docker-compose.example.yml` and `Dockerfile` for details.

# Usage

Example:

```
$ cp conf/redis.acl.example conf/redis.acl
$ docker compose -f docker-compose.example.yml up
$ redis-cli --insecure -u rediss://user1:pass@localhost:6380/1
```

## Sidekiq

```ruby
Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV["REDIS_URL"],
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  }
end
```

## Redis Cache Store

```ruby
config.cache_store = :redis_cache_store, {
  url: ENV["REDIS_URL"],
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
}
```

## Action Cable

```yml
# config/cable.yml

production:
  adapter: redis
  url: <%= ENV["REDIS_URL"] %>
  ssl_params:
    verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %>
```
