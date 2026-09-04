pub async fn fetch(url: &str) -> Result<String, Box<dyn std::error::Error>> {
    let body = client.get(url).await?;
    Ok(body)
}
