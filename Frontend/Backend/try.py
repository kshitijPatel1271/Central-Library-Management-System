import redis

r = redis.Redis(host='localhost', port=6379, db=0)

try:
    r.set('test', 'hello')
    print("Redis Connected! Value:", r.get('test').decode())
except Exception as e:
    print("Error:", e)
