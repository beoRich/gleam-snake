import gleam/float
import snake_types.{
  type BoxData, type Direction, type Model, BoxData, Down, Left, Right, Up,
  box_width,
}

import gleam/list

import tiramisu
import tiramisu/input

pub fn update_head_pos(
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

pub fn parse_direction_from_key(
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

pub fn is_gefressen_cal(model: Model) -> Bool {
  let threshold = 30.5
  let BoxData(hx, hy, _) = model.head
  let #(bx, by) = model.beute_pos
  float.absolute_value(hx -. bx) <. threshold
  && float.absolute_value(hy -. by) <. threshold
}

pub fn update_tail_pos(
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
    //todo
  }
  case update_movement {
    True -> new_tail
    False -> tail_pos
  }
}
