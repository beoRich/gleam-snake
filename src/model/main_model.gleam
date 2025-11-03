import gleam/option
import model/running_game_model
import snake_types.{type Model, type Msg, BoxData, Model, Right, Running, Tick}
import tiramisu/effect.{type Effect}

import tiramisu

pub fn init(
  _ctx: tiramisu.Context(String),
) -> #(Model, Effect(Msg), option.Option(_)) {
  #(
    Model(
      time: 0.0,
      head: BoxData(x: -450.0, y: 300.0, direction: Right),
      tail: [],
      beute_pos: #(0.0, 0.0),
      update_frame: 0,
      game_state: Running,
    ),
    effect.tick(Tick),
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
  }

  #(updatet_model, effect.tick(Tick), option.None)
}
