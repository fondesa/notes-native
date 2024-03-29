#include <iostream>
#include "sqlite_database.hpp"
#include "sqlite_exception.hpp"
#include "sqlite_statement.hpp"
#include "core/exception_macros.hpp"

namespace Db::Sql {

Database::Database(std::string dbPath, int flags) {
    auto movedPath = std::move(dbPath);
    int rc = sqlite3_open_v2(movedPath.c_str(), &db, flags, nullptr);
    if (rc != SQLITE_OK) {
        THROW(Db::Sql::Exception(db));
    }
    std::cout << "Opened database successfully" << std::endl;
}

Database::~Database() {
    sqlite3_close(db);
    std::cout << "Database closed" << std::endl;
}

void Database::executeTransaction(std::function<void()> transact) const {
    auto transaction = std::move(transact);
    int rc = sqlite3_exec(db, "BEGIN TRANSACTION", nullptr, nullptr, nullptr);
    if (rc != SQLITE_OK) {
        THROW(Db::Sql::Exception(db));
    }

    // Execute the transaction.
    transaction();

    rc = sqlite3_exec(db, "END TRANSACTION", nullptr, nullptr, nullptr);
    if (rc != SQLITE_OK) {
        THROW(Db::Sql::Exception(db));
    }
}

std::shared_ptr<Db::Statement> Database::createStatement(std::string sql) const {
    auto movedSql = std::move(sql);
    return std::make_shared<Statement>(db, movedSql);
}
}