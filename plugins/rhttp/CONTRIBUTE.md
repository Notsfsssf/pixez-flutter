## Generate Dart code after modifying the Rust code

Install the `flutter_rust_bridge_codegen` package:

```shell
cargo install flutter_rust_bridge_codegen
```

Run the following command to generate the Dart code:

Unix:

```shell
RUSTFLAGS='--cfg reqwest_unstable' flutter_rust_bridge_codegen generate
```

Windows (Powershell):

```shell
$env:RUSTFLAGS='--cfg reqwest_unstable'; flutter_rust_bridge_codegen generate
```
