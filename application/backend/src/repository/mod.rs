// Path: github.com/alexandertgtalbot/cloud-backend-showcase/application/backend/src/api/mod.rs
//
// Summary: Repository abstraction module.
//
// Operations:
// - User:
//   - Create user.
//   - Get user by username.
//   - Update user by username.
//   - Delete user by username.
//
// Engines:
// - SurrealDB.

pub mod surreal;

use crate::configs::Config;
use crate::models::user::User;

use std::fmt::{Display, Formatter};

pub enum Engine {
    Surrealdb(surreal::SurrealdbRepository),
}

#[async_trait::async_trait]
pub trait Repository {
    async fn create_user(&self, username: String, user_data: User)
        -> Result<User, RepositoryError>;

    async fn get_user(&self, username: String) -> Result<User, RepositoryError>;

    async fn update_user(&self, username: String, user_data: User)
        -> Result<User, RepositoryError>;

    async fn delete_user(&self, username: String) -> Result<(), RepositoryError>;
}

impl Engine {
    pub async fn connect(config: std::sync::Arc<Config>) -> Self {
        match config.repository.engine.as_str() {
            "surrealdb" => {
                let db = surreal::SurrealdbRepository::init(config.clone()).await;
                Engine::Surrealdb(db)
            }
            _ => panic!("Invalid DB Engine"),
        }
    }

    pub async fn create_user(
        &self,
        username: String,
        user_data: User,
    ) -> Result<User, RepositoryError> {
        match self {
            Engine::Surrealdb(db) => db.create_user(username, user_data).await,
        }
    }

    pub async fn get_user(&self, username: String) -> Result<User, RepositoryError> {
        match self {
            Engine::Surrealdb(db) => db.get_user(username).await,
        }
    }

    pub async fn update_user(
        &self,
        username: String,
        user_data: User,
    ) -> Result<User, RepositoryError> {
        match self {
            Engine::Surrealdb(db) => db.update_user(username, user_data).await,
        }
    }

    pub async fn delete_user(&self, username: String) -> Result<(), RepositoryError> {
        match self {
            Engine::Surrealdb(db) => db.delete_user(username).await,
        }
    }
}

#[derive(Debug)]
pub enum RepositoryError {
    NotFound(String),
    Duplicate(String),
    Unavailable(String),
}

impl Display for RepositoryError {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NotFound(id) => {
                write!(f, "The object, username = {}, does not exist.", id)
            }
            Self::Duplicate(e) => {
                write!(f, "Duplicate entry: {}", e)
            }
            Self::Unavailable(e) => {
                write!(f, "The configured repository is unavailable: {}", e)
            }
        }
    }
}
