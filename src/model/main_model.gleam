import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/javascript/promise
import gleam/json
import gleam/option
import gleam/result
import model/running_game_model
import snake_types.{
  type Model, type Msg, BoxData, FontLoadFailed, FontLoaded, Model, Right,
  Running, Tick, highscore_key,
}
import tiramisu/asset
import tiramisu/effect.{type Effect}

import tiramisu

pub fn init(
  ctx: tiramisu.Context(String),
) -> #(Model, Effect(Msg), option.Option(_)) {
  let load =
    asset.load_font("fonts/helvetiker_regular.typeface.json")
    |> promise.map(fn(result) {
      case result {
        Ok(font) -> FontLoaded(font)
        Error(err) -> FontLoadFailed(err)
      }
    })
  let init_beute_pos = running_game_model.random_pos(ctx)
  let pot_highscore =
    get_localstorage(highscore_key)
    |> result.try(fn(x) {
      let assert Ok(val) = decode.run(x, decode.int)
      Ok(val)
    })
  let highscore = option.from_result(pot_highscore)
  echo highscore
  #(
    Model(
      time: 0.0,
      head: BoxData(x: 0.0, y: 0.0, direction: Right),
      tail: [],
      beute_pos: init_beute_pos,
      update_frame: 0,
      game_state: Running,
      maybe_font: option.None,
      score: 0,
      highscore: highscore,
    ),
    effect.batch([effect.tick(Tick), effect.from_promise(load)]),
    option.None,
  )
}

pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(String),
) -> #(Model, Effect(Msg), option.Option(_)) {
  let updatet_model = case msg {
    Tick -> {
      case model.game_state {
        Running -> running_game_model.update_running_model(model, ctx)
        _ -> model
      }
    }
    FontLoaded(font) -> Model(..model, maybe_font: option.Some(font))
    FontLoadFailed(err) -> {
      echo err
      model
    }
    // handle error, maybe fallback
  }

  #(updatet_model, effect.tick(Tick), option.None)
}

@external(javascript, "./main_model.ffi.mjs", "get_localstorage")
fn get_localstorage(_key: String) -> Result(Dynamic, Nil) {
  Error(Nil)
}

fn highscore_decoder(json_string: String) -> Result(Int, json.DecodeError) {
  let highscore_decoder = {
    use highscore <- decode.field("Highscore", decode.int)
    decode.success(highscore)
  }

  json.parse(from: json_string, using: highscore_decoder)
}
