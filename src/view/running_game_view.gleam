import gleam/int
import gleam/list
import gleam/option
import gleam/string
import tiramisu
import tiramisu/geometry
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3

import snake_types.{type Model, box_width, color_hex}

pub fn create_running_game_view(
  model: Model,
  ctx: tiramisu.Context(String),
) -> List(scene.Node(String)) {
  let assert Ok(cube_geometry) =
    geometry.box(width: box_width, height: box_width, depth: 1.0)
  let assert Ok(head_material) =
    material.new()
    |> material.with_color(color_hex(snake_types.SnakeHeadColor))
    |> material.with_metalness(0.2)
    |> material.with_roughness(0.9)
    |> material.build()

  let assert Ok(beute_material) =
    material.new()
    |> material.with_color(color_hex(snake_types.BeuteColor))
    |> material.with_metalness(0.2)
    |> material.with_roughness(0.9)
    |> material.build()

  let head_position = vec3.Vec3(model.head.x, model.head.y, 0.0)
  let dynamic_elements = [
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
  dynamic_elements
}

fn tail_elements(model: Model) -> List(scene.Node(String)) {
  let assert Ok(cube_geometry) =
    geometry.box(width: box_width, height: box_width, depth: 1.0)

  let assert Ok(tail_material) =
    material.new()
    |> material.with_color(color_hex(snake_types.SnakeTailColor))
    |> material.with_metalness(0.2)
    |> material.with_roughness(0.9)
    |> material.build()
  model.tail
  |> list.map(fn(tail_element) { #(tail_element.x, tail_element.y) })
  |> list.index_map(fn(tuple, index) {
    create_box_cell_mesh(tuple.0, tuple.1, index, cube_geometry, tail_material)
  })
}

fn create_box_cell_mesh(
  x: Float,
  y: Float,
  index: Int,
  cube_geometry: geometry.Geometry,
  tail_material: material.Material,
) -> scene.Node(String) {
  scene.mesh(
    id: string.append("TailElement", int.to_string(index)),
    geometry: cube_geometry,
    material: tail_material,
    transform: transform.at(position: vec3.Vec3(x, y, 0.0)),
    physics: option.None,
  )
}
