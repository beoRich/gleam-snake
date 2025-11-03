import gleam/option
import model/main_model
import tiramisu
import tiramisu/background
import view/main_view

pub fn main() -> Nil {
  tiramisu.run(
    dimensions: option.None,
    background: background.Color(0x162b1e),
    init: main_model.init,
    update: main_model.update,
    view: main_view.view,
  )
}
