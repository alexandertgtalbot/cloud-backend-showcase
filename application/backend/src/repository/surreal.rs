// Path: github.com/alexandertgtalbot/cloud-backend-showcase/application/backend/src/repository/surreal.rs
//
// Summary: SurrealDB repository receiver functions.
//
// Operations:
// - User:
//   - Create user.
//   - Get user by username.
//   - Update user by username.
//   - Delete user by username.

use crate::models::user::User;
use crate::repository::{Repository, RepositoryError};

use serde::{Deserialize, Serialize};
use surrealdb::sql::Thing;

pub struct SurrealdbRepository {
    config: std::sync::Arc<crate::configs::Config>,
    db: surrealdb::Surreal<surrealdb::engine::local::Db>,
}

impl SurrealdbRepository {
    pub async fn init(config: std::sync::Arc<crate::configs::Config>) -> Self {
        let db = surrealdb::Surreal::new::<surrealdb::engine::local::Mem>(())
            .await
            .unwrap();
        SurrealdbRepository { config, db }
    }
}

#[derive(Debug, Deserialize, Serialize)]
struct Record {
    #[allow(dead_code)]
    id: Thing,
}

impl From<surrealdb::Error> for RepositoryError {
    fn from(error: surrealdb::Error) -> Self {
        match error {
            surrealdb::Error::Db(error) => match error {
                surrealdb::error::Db::RecordExists { thing } => {
                    RepositoryError::Duplicate(thing.to_string())
                }
                _ => RepositoryError::Unavailable(error.to_string()),
            },
            surrealdb::Error::Api(error) => RepositoryError::Unavailable(error.to_string()),
        }
    }
}

#[async_trait::async_trait]
impl Repository for SurrealdbRepository {
    async fn create_user(
        &self,
        username: String,
        user_data: User,
    ) -> Result<User, RepositoryError> {
        self.db
            .use_ns(self.config.repository.namespace.as_str())
            .use_db(self.config.repository.database.as_str())
            .await?;

        let result: Option<Record> = self
            .db
            .create(("user", &username))
            .content(&user_data)
            .await?;

        match result {
            Some(_) => Ok(user_data),
            None => Err(RepositoryError::Unavailable(
                "Failed to create user".to_string(),
            )),
        }
    }

    async fn get_user(&self, username: String) -> Result<User, RepositoryError> {
        self.db
            .use_ns(self.config.repository.namespace.as_str())
            .use_db(self.config.repository.database.as_str())
            .await?;

        let user: Option<User> = self.db.select(("user", &username)).await?;

        match user {
            Some(user) => Ok(user),
            None => Err(RepositoryError::Unavailable(
                "Failed to create user".to_string(),
            )),
        }
    }

    async fn update_user(
        &self,
        username: String,
        user_data: User,
    ) -> Result<User, RepositoryError> {
        self.db
            .use_ns(self.config.repository.namespace.as_str())
            .use_db(self.config.repository.database.as_str())
            .await?;

        let result: Option<Record> = self
            .db
            .update(("user", &username))
            .content(&user_data)
            .await?;

        match result {
            Some(_) => Ok(user_data),
            None => Err(RepositoryError::Unavailable(
                "Failed to update user".to_string(),
            )),
        }
    }

    async fn delete_user(&self, username: String) -> Result<(), RepositoryError> {
        self.db
            .use_ns(self.config.repository.namespace.as_str())
            .use_db(self.config.repository.database.as_str())
            .await?;

        let result: Option<Record> = self.db.delete(("user", &username)).await?;

        match result {
            Some(_) => Ok(()),
            None => Err(RepositoryError::Unavailable(
                "Failed to update user".to_string(),
            )),
        }
    }
}
