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

pub struct SurrealdbRepository {
    _config: std::sync::Arc<crate::configs::Config>,
    _db: surrealdb::Surreal<surrealdb::engine::local::Db>,
}

impl SurrealdbRepository {
    pub async fn init(_config: std::sync::Arc<crate::configs::Config>) -> Self {
        todo!()
    }
}

#[async_trait::async_trait]
impl Repository for SurrealdbRepository {
    async fn create_user(
        &self,
        _username: String,
        _user_data: User,
    ) -> Result<User, RepositoryError> {
        todo!()
    }

    async fn get_user(&self, _username: String) -> Result<User, RepositoryError> {
        todo!()
    }

    async fn update_user(
        &self,
        _username: String,
        _user_data: User,
    ) -> Result<User, RepositoryError> {
        todo!()
    }

    async fn delete_user(&self, _username: String) -> Result<User, RepositoryError> {
        todo!()
    }
}
