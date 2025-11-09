import gleam/option
import main_view
import model_update
import tiramisu
import tiramisu/background

pub fn main() -> Nil {
  tiramisu.run(
    dimensions: option.None,
    background: background.Color(0x162b1e),
    init: model_update.init,
    update: model_update.update,
    view: main_view.view,
  )
}
