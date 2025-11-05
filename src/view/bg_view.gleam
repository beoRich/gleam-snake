import gleam/int
import gleam/option
import gleam/string
import tiramisu
import tiramisu/geometry
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3

import snake_global
import snake_types.{type Model, box_width}

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
  let borders = [
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

  borders
}

pub fn create_game_over(model: Model, ctx: tiramisu.Context(String)) {
  let assert Ok(game_over_text_material) =
    material.new()
    |> material.with_color(0xeb0933)
    |> material.with_metalness(0.0)
    |> material.with_roughness(0.7)
    |> material.build()
  let score_string =
    string.append("GAME OVER FINAL SCORE: ", int.to_string(model.score))
  let text_elements = case model.maybe_font {
    option.Some(font) -> {
      let assert Ok(game_over_text) =
        geometry.text(
          text: score_string,
          font: font,
          size: 50.0,
          depth: 0.2,
          curve_segments: 12,
          bevel_enabled: True,
          bevel_thickness: 0.05,
          bevel_size: 0.02,
          bevel_offset: 0.0,
          bevel_segments: 5,
        )

      let text_scene =
        scene.mesh(
          id: "game over display",
          geometry: game_over_text,
          material: game_over_text_material,
          transform: transform.at(position: vec3.Vec3(0.0 -. 450.0, 0.0, 0.0)),
          physics: option.None,
        )
      [text_scene]
    }
    _ -> []
  }
  text_elements
}

pub fn create_score_display(
  model: Model,
  ctx: tiramisu.Context(String),
) -> List(scene.Node(String)) {
  let assert Ok(score_text_material) =
    material.new()
    |> material.with_color(0x34d0eb)
    |> material.with_metalness(0.0)
    |> material.with_roughness(0.7)
    |> material.build()
  let score_string = string.append("Score: ", int.to_string(model.score))
  let complete_score = case model.highscore {
    option.Some(val) ->
      score_string <> " (Highscore: " <> int.to_string(val) <> ")"
    _ -> score_string
  }
  let text_elements = case model.maybe_font {
    option.Some(font) -> {
      let assert Ok(text) =
        geometry.text(
          text: complete_score,
          font: font,
          size: 36.0,
          depth: 0.2,
          curve_segments: 12,
          bevel_enabled: True,
          bevel_thickness: 0.05,
          bevel_size: 0.02,
          bevel_offset: 0.0,
          bevel_segments: 5,
        )

      let text_scene =
        scene.mesh(
          id: "score_display",
          geometry: text,
          material: score_text_material,
          transform: transform.at(position: vec3.Vec3(
            0.0 -. 200.0,
            snake_global.upper_border(ctx)
              +. snake_global.horz_border_dist()
              /. 2.0,
            0.0,
          )),
          physics: option.None,
        )
      [text_scene]
    }
    _ -> []
  }
  text_elements
}
