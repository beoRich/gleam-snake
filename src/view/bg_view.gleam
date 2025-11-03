import gleam/option
import tiramisu
import tiramisu/geometry
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3

import snake_global
import snake_types.{box_width}

pub fn create_static_view(
  ctx: tiramisu.Context(String),
) -> List(scene.Node(String)) {
  let assert Ok(border_material) =
    material.new()
    |> material.with_color(0xeb4034)
    |> material.with_metalness(0.2)
    |> material.with_roughness(0.9)
    |> material.build()
  let assert Ok(horizontal_border_geometry) =
    geometry.box(width: ctx.canvas_width, height: box_width /. 5.0, depth: 1.0)

  let assert Ok(vertical_border_geometry) =
    geometry.box(
      width: box_width /. 5.0,
      height: ctx.canvas_height -. 2.0 *. snake_global.horz_border_dist(),
      depth: 1.0,
    )
  [
    scene.mesh(
      id: "upperLine",
      geometry: horizontal_border_geometry,
      material: border_material,
      transform: transform.at(position: vec3.Vec3(
        0.0,
        snake_global.upper_border(ctx),
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
        snake_global.down_border(ctx),
        0.0,
      )),
      physics: option.None,
    ),

    scene.mesh(
      id: "leftLine",
      geometry: vertical_border_geometry,
      material: border_material,
      transform: transform.at(position: vec3.Vec3(
        snake_global.left_border(ctx),
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
        snake_global.right_border(ctx),
        0.0,
        0.0,
      )),
      physics: option.None,
    ),
  ]
}
