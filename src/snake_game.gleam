/// 2D Game Example - Orthographic Camera
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import snake_movement
import tiramisu
import tiramisu/background
import tiramisu/camera
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/light
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3

import snake_types.{
  type Model, type Msg, BoxData, Down, Left, Model, Right, Running, Tick, Up,
  box_width,
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
      game_state: Running,
    ),
    effect.tick(Tick),
    option.None,
  )
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(String),
) -> #(Model, Effect(Msg), option.Option(_)) {
  case msg {
    Tick -> {
      let new_time = ctx.delta_time
      let new_direction =
        snake_movement.parse_direction_from_key(ctx, model.head.direction)
      let is_grefressen = snake_movement.is_gefressen_cal(model)

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
        snake_movement.update_tail_pos(
          model.head,
          enhanced_tail,
          model.update_frame,
        )

      let #(new_x, new_y) =
        snake_movement.update_head_pos(
          model.head,
          model.update_frame,
          new_direction,
        )

      #(
        Model(
          time: new_time,
          head: BoxData(x: new_x, y: new_y, direction: new_direction),
          tail: new_tail,
          beute_pos: new_beute_pos,
          update_frame: { model.update_frame + 1 } % 8,
          game_state: Running,
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
  let assert Ok(horizontal_border_geometry) =
    geometry.box(width: ctx.canvas_width, height: box_width /. 5.0, depth: 1.0)

  let assert Ok(vertical_border_geometry) =
    geometry.box(
      width: box_width /. 5.0,
      height: ctx.canvas_height -. 6.0 *. box_width,
      depth: 1.0,
    )
  let assert Ok(cube_geometry) =
    geometry.box(width: box_width, height: box_width, depth: 1.0)
  let assert Ok(head_material) =
    material.new()
    |> material.with_color(0x34eb4c)
    |> material.with_metalness(0.2)
    |> material.with_roughness(0.9)
    |> material.build()

  let assert Ok(border_material) =
    material.new()
    |> material.with_color(0xeb4034)
    |> material.with_metalness(0.2)
    |> material.with_roughness(0.9)
    |> material.build()

  let assert Ok(beute_material) =
    material.new()
    |> material.with_color(0xfcba03)
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
      id: "upperLine",
      geometry: horizontal_border_geometry,
      material: border_material,
      transform: transform.at(position: vec3.Vec3(
        0.0,
        0.0 +. ctx.canvas_height /. 2.0 -. 3.0 *. box_width,
        0.0,
      )),
      physics: option.None,
    ),

    scene.mesh(
      id: "downLine",
      geometry: horizontal_border_geometry,
      material: border_material,
      transform: transform.at(position: vec3.Vec3(
        0.0,
        0.0 -. { ctx.canvas_height /. 2.0 -. 3.0 *. box_width },
        0.0,
      )),
      physics: option.None,
    ),

    scene.mesh(
      id: "leftLine",
      geometry: vertical_border_geometry,
      material: border_material,
      transform: transform.at(position: vec3.Vec3(
        0.0 -. ctx.canvas_width /. 2.0,
        0.0,
        0.0,
      )),
      physics: option.None,
    ),

    scene.mesh(
      id: "rightLine",
      geometry: vertical_border_geometry,
      material: border_material,
      transform: transform.at(position: vec3.Vec3(
        0.0 +. ctx.canvas_width /. 2.0,
        0.0,
        0.0,
      )),
      physics: option.None,
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
    ..tail_elements(model)
  ]
  base_elements
}

fn tail_elements(model: Model) -> List(scene.Node(String)) {
  model.tail
  |> list.map(fn(tail_element) { #(tail_element.x, tail_element.y) })
  |> list.index_map(fn(tuple, index) {
    create_box_cell_mesh(tuple.0, tuple.1, index)
  })
}
