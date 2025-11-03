import gleam/option
import snake_model
import tiramisu
import tiramisu/background
import view/main_view

pub fn main() -> Nil {
  tiramisu.run(
    dimensions: option.None,
    background: background.Color(0x162b1e),
    init: snake_model.init,
    update: snake_model.update,
    view: main_view.view,
  )
}
