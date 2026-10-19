use std::process::ExitCode;

use game10::{app, cli};

fn main() -> ExitCode {
    let options = match cli::parse(std::env::args().skip(1)) {
        Ok(options) => options,
        Err(e) => {
            eprintln!("game10: {e}\n{}", cli::USAGE);
            return ExitCode::from(2);
        }
    };
    match app::run(options) {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("game10: {e}");
            ExitCode::FAILURE
        }
    }
}
