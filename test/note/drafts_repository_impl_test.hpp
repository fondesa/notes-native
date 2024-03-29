#pragma once

#include <gtest/gtest.h>
#include "core/include_macros.hpp"
#include "note/drafts_repository_impl.hpp"
#include AMALGAMATION(database.hpp)

class DraftsRepositoryImplTest : public ::testing::Test {
   protected:
    std::shared_ptr<DraftsRepositoryImpl> repository;
    std::shared_ptr<Db::Database> db;

    void SetUp() override;

    void TearDown() override;

    int getPendingNewDraftsCount();

    int getPendingExistingDraftsCount();
};