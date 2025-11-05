import gleam/javascript/promise
import gleam/option
import model/running_game_model
import snake_types.{
  type Model, type Msg, BoxData, FontLoadFailed, FontLoaded, Model, Right,
  Running, Tick,
}
import tiramisu/asset
import tiramisu/effect.{type Effect}

import tiramisu

pub fn init(
  _ctx: tiramisu.Context(String),
) -> #(Model, Effect(Msg), option.Option(_)) {
  let load =
    asset.load_font("fonts/helvetiker_regular.typeface.json")
    |> promise.map(fn(result) {
      case result {
        Ok(font) -> FontLoaded(font)
        Error(err) -> FontLoadFailed(err)
      }
    })
  #(
    Model(
      time: 0.0,
      head: BoxData(x: 0.0, y: 0.0, direction: Right),
      tail: [],
      beute_pos: #(0.0, 0.0),
      update_frame: 0,
      game_state: Running,
      maybe_font: option.None,
      score: 0,
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
