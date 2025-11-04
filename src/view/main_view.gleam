import gleam/float
import gleam/list
import gleam/option
import tiramisu
import tiramisu/camera
import tiramisu/light
import tiramisu/scene
import tiramisu/transform
import vec/vec3
import view/bg_view
import view/running_game_view

import snake_types.{type Model, Running}

pub fn view(
  model: Model,
  ctx: tiramisu.Context(String),
) -> List(scene.Node(String)) {
  let cam =
    camera.camera_2d(
      width: float.round(ctx.canvas_width),
      height: float.round(ctx.canvas_height),
    )

  let init_elements = [
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
  ]
  let base_elements =
    list.append(init_elements, bg_view.create_static_view(ctx))
    |> list.append(bg_view.create_score_display(model, ctx))

  case model.game_state {
    Running -> {
      list.append(
        base_elements,
        running_game_view.create_running_game_view(model, ctx),
      )
    }
    _ -> base_elements
  }
}
