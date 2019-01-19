# MicroTimer 

[![Hex pm](https://img.shields.io/hexpm/v/micro_timer.svg?style=flat)](https://hex.pm/packages/micro_timer) [![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/micro_timer/)

A timer module with microsend resolution.

`MicroTimer` can sleep for as low as it takes to the `BEAM` to send a message 
(usually 3-5µ).  
It can also send messages and invoke functions after a `timeout` or repeatedly
every `timeout` µs.  

Keep in mind that the system `sleep` primitive literally waits doing nothing, consuming no CPU whatsoever, while `µsleep` is implemented with message passing
and wastes CPU cycles for a maximum of 2ms per call.

The CPU load shouldn't be a problem anyway, but it's definitely non-zero.

## Installation

The package can be installed by adding `micro_timer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:micro_timer, "~> 0.1.0"}
  ]
end
```

## API

**MicroTimer** has a very simple API

- `usleep(timeout)` and the alias `µsleep(timeout)`  
  sleep for `timeout` µs.

- `apply_after(timeout, executable, args \\ [])`  
  invoke the `executable` after `timeout` µs with the args `args`  
  `executable` can be the tuple `{Module, :function}` or a function 
  
- `apply_every(timeout, executable, args \\ [])`  
  invoke the `executable` every `timeout` µs with the args `args`  
  
- `send_after(timeout, message, pid \\ self())`  
  send `message` after `timeout` µs to `pid`  
  if `pid` is empty, the message is sento to `self()`

- `send_every(timeout, message, pid \\ self())`  
  send `message` every `timeout` µs to `pid`
  
- `cancel_timer(timer)`  
  cancel the `timer` created by one of `apply_after`, `apply_every`, `send_after` and `send_every`  

`*_after` and `*_avery` return a timer reference that is just a regular `pid`.  
You can check if the timer is still active or not with a simple call to `Process.alive?(pid)`

## Basic Usage

```elixir
iex(1)> :timer.tc(fn -> MicroTimer.usleep(250) end)
{257, :ok}

iex(2)> MicroTimer.send_after(666, :msg)
#PID<0.222.0>
# approximately 666µs later
iex(3)> flush
:msg
:ok
```

Check out the [`examples`](examples/) folder in this repository for more realistic examples.

Full documentation can be found at [https://hexdocs.pm/micro_timer](https://hexdocs.pm/micro_timer).

## Benchmarks

[Google Drive spreadsheet](https://docs.google.com/spreadsheets/u/2/d/e/2PACX-1vTmvR8JOpVriDxXGv3UJpsxEMN4hIa56NYrCgRCc_V3OPxkixaNat6lgzUOr1lr2ftTih972TlsWdM9/pubhtml) 

## License

**MicroTimer** is released under the MIT License - see the [LICENSE](LICENSE) file.

