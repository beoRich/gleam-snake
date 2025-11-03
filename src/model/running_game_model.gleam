import gleam/float
import gleam/int
import gleam/option
import snake_types.{
  type BoxData, type Direction, type Model, type Msg, BoxData, Down, GameOver,
  Left, Model, Right, Running, Tick, Up, box_width,
}

import snake_global
import tiramisu/effect.{type Effect}

import gleam/list

import tiramisu
import tiramisu/input

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

pub fn update_running_model(
  model: Model,
  ctx: tiramisu.Context(String),
) -> Model {
  let is_game_over = check_game_over(model, ctx)
  case is_game_over {
    True -> Model(..model, game_state: GameOver)
    False -> update_snake_beute(model, ctx)
  }
}

fn check_game_over(model: Model, ctx: tiramisu.Context(String)) -> Bool {
  model.head.x >. snake_global.right_border(ctx)
  || model.head.x <. snake_global.left_border(ctx)
  || model.head.y >. snake_global.upper_border(ctx)
  || model.head.y <. snake_global.down_border(ctx)
}

fn update_snake_beute(model: Model, ctx: tiramisu.Context(String)) -> Model {
  let new_time = ctx.delta_time
  let new_direction = parse_direction_from_key(ctx, model.head.direction)
  let is_grefressen = is_gefressen_cal(model)

  let new_beute_pos = case is_grefressen {
    False -> model.beute_pos
    _ -> #(
      int.to_float(int.random(10)) *. box_width,
      -200.0 +. int.to_float(int.random(10)) *. box_width,
    )
  }

  let enhanced_tail = case is_grefressen {
    False -> model.tail
    _ -> {
      let last_element = case model.tail {
        [] -> model.head
        [_, ..] -> {
          let assert Ok(last_element) = list.last(model.tail)
          last_element
        }
      }
      let new_tail_element = case last_element.direction {
        Right -> BoxData(..last_element, x: last_element.x -. box_width)
        Left -> BoxData(..last_element, x: last_element.x +. box_width)
        Up -> BoxData(..last_element, y: last_element.y -. box_width)
        Down -> BoxData(..last_element, y: last_element.y +. box_width)
      }
      list.append(model.tail, [new_tail_element])
    }
  }

  let new_tail = update_tail_pos(model.head, enhanced_tail, model.update_frame)

  let #(new_x, new_y) =
    update_head_pos(model.head, model.update_frame, new_direction)

  Model(
    time: new_time,
    head: BoxData(x: new_x, y: new_y, direction: new_direction),
    tail: new_tail,
    beute_pos: new_beute_pos,
    update_frame: { model.update_frame + 1 } % 8,
    game_state: Running,
  )
}

fn update_head_pos(
  box_data: BoxData,
  update_frame: Int,
  direction: Direction,
) -> #(Float, Float) {
  let update_movement = update_frame == 0

  let horizontal_mov = case direction {
    Right -> box_width
    Left -> float.negate(box_width)
    _ -> 0.0
  }

  let vertical_mov = case direction {
    Up -> box_width
    Down -> float.negate(box_width)
    _ -> 0.0
  }
  case update_movement {
    True -> #(box_data.x +. horizontal_mov, box_data.y +. vertical_mov)
    False -> #(box_data.x, box_data.y)
  }
}

fn parse_direction_from_key(
  ctx: tiramisu.Context(String),
  old_direction: Direction,
) -> Direction {
  let is_left = input.is_key_just_pressed(ctx.input, input.ArrowLeft)
  let is_right = input.is_key_just_pressed(ctx.input, input.ArrowRight)
  let is_up = input.is_key_just_pressed(ctx.input, input.ArrowUp)
  let is_down = input.is_key_just_pressed(ctx.input, input.ArrowDown)
  case is_left, is_right, is_up, is_down {
    True, _, _, _ -> Left
    _, True, _, _ -> Right
    _, _, True, _ -> Up
    _, _, _, True -> Down
    _, _, _, _ -> old_direction
  }
}

fn is_gefressen_cal(model: Model) -> Bool {
  let threshold = 30.5
  let BoxData(hx, hy, _) = model.head
  let #(bx, by) = model.beute_pos
  float.absolute_value(hx -. bx) <. threshold
  && float.absolute_value(hy -. by) <. threshold
}

fn update_tail_pos(
  head_pos: BoxData,
  tail_pos: List(BoxData),
  update_frame: Int,
) -> List(BoxData) {
  let update_movement = update_frame == 0
  let new_tail = case tail_pos {
    [] -> tail_pos
    [_] -> [head_pos]
    _ ->
      list.append(
        [head_pos],
        list.reverse(tail_pos) |> list.drop(1) |> list.reverse,
      )
  }
  case update_movement {
    True -> new_tail
    False -> tail_pos
  }
}
