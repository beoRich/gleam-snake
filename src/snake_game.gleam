/// 2D Game Example - Orthographic Camera
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import tiramisu
import tiramisu/background
import tiramisu/camera
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/input
import tiramisu/light
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3

const box_width = 50.0

pub type Model {
  Model(
    time: Float,
    head: BoxData,
    tail: List(BoxData),
    beute_pos: #(Float, Float),
    update_frame: Int,
  )
}

pub type BoxData {
  BoxData(x: Float, y: Float, direction: Direction)
}

pub type Direction {
  Right
  Left
  Up
  Down
}

pub type Msg {
  Tick
}

pub fn main() -> Nil {
  tiramisu.run(
    dimensions: option.None,
    background: background.Color(0x162b1e),
    init: init,
    update: update,
    view: view,
  )
}

fn init(
  _ctx: tiramisu.Context(String),
) -> #(Model, Effect(Msg), option.Option(_)) {
  #(
    Model(
      time: 0.0,
      head: BoxData(x: -450.0, y: 300.0, direction: Right),
      tail: [],
      beute_pos: #(0.0, 0.0),
      update_frame: 0,
    ),
    effect.tick(Tick),
    option.None,
  )
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
    //todo
  }
  case update_movement {
    True -> new_tail
    False -> tail_pos
  }
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(String),
) -> #(Model, Effect(Msg), option.Option(_)) {
  case msg {
    Tick -> {
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

      let new_tail =
        update_tail_pos(model.head, enhanced_tail, model.update_frame)

      let #(new_x, new_y) =
        update_head_pos(model.head, model.update_frame, new_direction)

      echo #(new_x, new_y)
      echo new_tail
      #(
        Model(
          time: new_time,
          head: BoxData(x: new_x, y: new_y, direction: new_direction),
          tail: new_tail,
          beute_pos: new_beute_pos,
          update_frame: { model.update_frame + 1 } % 8,
        ),
        effect.tick(Tick),
        option.None,
      )
    }
  }
}

fn create_box_cell_mesh(x: Float, y: Float, index: Int) -> scene.Node(String) {
  let assert Ok(cube_geometry) =
    geometry.box(width: box_width, height: box_width, depth: 1.0)

  let assert Ok(tail_material) =
    material.new()
    |> material.with_color(0x42f5b6)
    |> material.with_metalness(0.2)
    |> material.with_roughness(0.9)
    |> material.build()
  scene.mesh(
    id: string.append("TailElement", int.to_string(index)),
    geometry: cube_geometry,
    material: tail_material,
    transform: transform.at(position: vec3.Vec3(x, y, 0.0)),
    physics: option.None,
  )
}

fn view(model: Model, ctx: tiramisu.Context(String)) -> List(scene.Node(String)) {
  let cam =
    camera.camera_2d(
      width: float.round(ctx.canvas_width),
      height: float.round(ctx.canvas_height),
    )
  let assert Ok(cube_geometry) =
    geometry.box(width: box_width, height: box_width, depth: 1.0)
  let assert Ok(head_material) =
    material.new()
    |> material.with_color(0x34eb4c)
    |> material.with_metalness(0.2)
    |> material.with_roughness(0.9)
    |> material.build()

  let assert Ok(beute_material) =
    material.new()
    |> material.with_color(0xeb4034)
    |> material.with_metalness(0.2)
    |> material.with_roughness(0.9)
    |> material.build()

  let head_position = vec3.Vec3(model.head.x, model.head.y, 0.0)
  let base_elements = [
    scene.camera(
      id: "camera",
      camera: cam,
      transform: transform.at(position: vec3.Vec3(0.0, 0.0, 20.0)),
      look_at: option.None,
      active: True,
      viewport: option.None,
    ),
    scene.light(
      id: "ambient",
      light: {
        let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 1.0)
        light
      },
      transform: transform.identity,
    ),
    scene.mesh(
      id: "snakeHead",
      geometry: cube_geometry,
      material: head_material,
      transform: transform.at(position: head_position),
      physics: option.None,
    ),

    scene.mesh(
      id: "beute",
      geometry: cube_geometry,
      material: beute_material,
      transform: transform.at(position: vec3.Vec3(
        model.beute_pos.0,
        model.beute_pos.1,
        0.0,
      )),
      physics: option.None,
    ),
    ..model.tail
    |> list.map(fn(tail_element) { #(tail_element.x, tail_element.y) })
    |> list.index_map(fn(tuple, index) {
      create_box_cell_mesh(tuple.0, tuple.1, index)
    })
  ]
  base_elements
}
