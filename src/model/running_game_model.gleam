import gleam/float
import gleam/int
import gleam/option
import snake_types.{
  type BoxData, type Direction, type Model, BoxData, Down, GameOver, Left, Model,
  Right, Running, Up, box_width, highscore_key,
}

import snake_global

import gleam/list

import tiramisu
import tiramisu/input

pub fn update_running_model(
  model: Model,
  ctx: tiramisu.Context(String),
) -> Model {
  let is_game_over = check_game_over(model, ctx)
  case is_game_over {
    True -> {
      let score = model.score
      let pot_new_highscore = case model.highscore {
        option.Some(highscore_val) ->
          case score > highscore_val {
            True -> {
              set_localstorage(highscore_key, int.to_string(score))

              score
            }
            _ -> highscore_val
          }
        _ -> score
      }
      Model(
        ..model,
        game_state: GameOver,
        highscore: option.Some(pot_new_highscore),
      )
    }
    False -> update_snake_beute(model, ctx)
  }
}

fn check_game_over(model: Model, ctx: tiramisu.Context(String)) -> Bool {
  let hx = model.head.x
  let hy = model.head.y
  let border_check =
    hx >. snake_global.right_border(ctx)
    || hx <. snake_global.left_border(ctx)
    || hy >. snake_global.upper_border(ctx)
    || hy <. snake_global.down_border(ctx)

  let own_tail_check = list.any(model.tail, fn(a) { a.x == hx && a.y == hy })
  case own_tail_check {
    True -> echo "Game Over due to own tail crash"
    _ -> {
      ""
    }
  }
  border_check || own_tail_check
}

fn calculate_new_beute_pos(
  model: Model,
  safety: Int,
  ctx: tiramisu.Context(String),
) -> #(Float, Float) {
  let cand = random_pos(ctx)
  let test_function = spawn_too_close(_, cand)
  let too_close =
    list.append([model.head], model.tail) |> list.any(test_function)
  case too_close && safety < 5 {
    True -> {
      calculate_new_beute_pos(model, safety + 1, ctx)
    }
    False -> cand
  }
}

pub fn random_pos(ctx: tiramisu.Context(String)) -> #(Float, Float) {
  let abs_x = ctx.canvas_height -. 2.0 *. box_width
  let rand_x = float.round(abs_x /. box_width) - 1

  let abs_y =
    ctx.canvas_height
    -. 2.0
    *. snake_global.horz_border_dist()
    -. 2.0
    *. box_width
  let rand_y = float.round(abs_y /. box_width) - 1
  let cand = #(
    int.to_float(int.random(rand_x) - rand_x / 2) *. box_width,
    int.to_float(int.random(rand_y) - rand_y / 2) *. box_width,
  )
  cand
}

fn spawn_too_close(snake_element: BoxData, cand: #(Float, Float)) -> Bool {
  let dist_x = float.absolute_value(snake_element.x -. cand.0)
  let dist_y = float.absolute_value(snake_element.y -. cand.1)
  dist_x <. 2.0 *. box_width && dist_y <. 2.0 *. box_width
}

fn update_snake_beute(model: Model, ctx: tiramisu.Context(String)) -> Model {
  let new_time = ctx.delta_time
  let new_direction = parse_direction_from_key(ctx, model)
  let is_grefressen = is_gefressen_cal(model)

  let new_score = case is_grefressen {
    True -> model.score + 1
    False -> model.score
  }

  let new_beute_pos = case is_grefressen {
    False -> model.beute_pos
    _ -> calculate_new_beute_pos(model, 0, ctx)
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
    ..model,
    time: new_time,
    head: BoxData(x: new_x, y: new_y, direction: new_direction),
    tail: new_tail,
    beute_pos: new_beute_pos,
    update_frame: { model.update_frame + 1 } % 8,
    game_state: Running,
    score: new_score,
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
  model: Model,
) -> Direction {
  let is_left = input.is_key_just_pressed(ctx.input, input.ArrowLeft)
  let is_right = input.is_key_just_pressed(ctx.input, input.ArrowRight)
  let is_up = input.is_key_just_pressed(ctx.input, input.ArrowUp)
  let is_down = input.is_key_just_pressed(ctx.input, input.ArrowDown)
  case is_left, is_right, is_up, is_down {
    True, _, _, _ -> check_if_new_is_pos(Left, model)
    _, True, _, _ -> check_if_new_is_pos(Right, model)
    _, _, True, _ -> check_if_new_is_pos(Up, model)
    _, _, _, True -> check_if_new_is_pos(Down, model)
    _, _, _, _ -> model.head.direction
  }
}

fn check_if_new_is_pos(new_direction: Direction, model: Model) -> Direction {
  case list.is_empty(model.tail) {
    True -> new_direction
    _ -> {
      let assert Ok(first_tail) = list.first(model.tail)
      let head = model.head
      let old_direction = head.direction
      case new_direction {
        Right ->
          if_true_old_else(
            first_tail.x >. head.x && first_tail.y == head.y,
            old_direction,
            new_direction,
          )
        Left ->
          if_true_old_else(
            first_tail.x <. head.x && first_tail.y == head.y,
            old_direction,
            new_direction,
          )
        Up ->
          if_true_old_else(
            first_tail.y >. head.y && first_tail.x == head.x,
            old_direction,
            new_direction,
          )
        Down ->
          if_true_old_else(
            first_tail.y <. head.y && first_tail.x == head.x,
            old_direction,
            new_direction,
          )
        _ -> new_direction
      }
    }
  }
}

fn if_true_old_else(
  is_true: Bool,
  old_direction: Direction,
  new_direction: Direction,
) -> Direction {
  case is_true {
    True -> old_direction
    False -> new_direction
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

@external(javascript, "./local_storage.ffi.mjs", "set_localstorage")
fn set_localstorage(_key: String, _value: String) -> Nil {
  Nil
}
