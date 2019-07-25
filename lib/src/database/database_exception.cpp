#include <utility>

#include "database_exception.hpp"

DatabaseException::DatabaseException(std::string msg) {
    this->msg = std::move(msg);
}

const char *DatabaseException::what() const noexcept {
    return msg.c_str();
}
