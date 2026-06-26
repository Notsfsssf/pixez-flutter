# benchmark

Start server:

```shell
cd nodejs
node server.js
```

Start benchmark:

```shell
cd benchmark
flutter run --release
```

## 1 KB x 10000
- rhttp: 1010 ms
- http: 2174 ms
- dio: 2758 ms

## 10 MB x 100
- rhttp: 2394 ms
- http: 12527 ms
- dio: 13091 ms
