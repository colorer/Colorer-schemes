#![allow(dead_code)]

fn main() {
    let s = r#"hello "world""#;
    let t = r##"foo #"bar"#"##;
    let a: &'static str = "x";
    let c = 'z';
    #[derive(Debug)]
    struct Point;
}
