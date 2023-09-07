// Path: github.com/alexandertgtalbot/cloud-backend-showcase/application/backend/src/configs/mod.rs
//
// Summary: Configuration module for structuring environment variable configurations.

use envconfig::Envconfig;

#[derive(Envconfig, Debug)]
pub struct Config {
    #[envconfig(nested = true)]
    pub repository: RepositoryConfig,

    #[envconfig(from = "WEB_FRAMEWORK", default = "actix")]
    pub web_framework: String,
}

#[derive(Envconfig, Debug)]
pub struct RepositoryConfig {
    #[envconfig(from = "REPOSITORY_ENGINE", default = "surrealdb")]
    pub engine: String,

    #[envconfig(from = "REPOSITORY_URI", default = "")]
    pub uri: String,

    #[envconfig(from = "REPOSITORY_USERNAME", default = "")]
    pub username: String,

    #[envconfig(from = "REPOSITORY_PASSWORD", default = "")]
    pub password: String,

    #[envconfig(from = "REPOSITORY_NAMESPACE", default = "")]
    pub namespace: String,

    #[envconfig(from = "REPOSITORY_DATABASE", default = "")]
    pub database: String,
}
