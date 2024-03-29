#pragma once

#include <gtest/gtest.h>
#include "core/include_macros.hpp"
#include "note/notes_repository_impl.hpp"
#include "time/mock/clock_mock.hpp"
#include AMALGAMATION(database.hpp)

class NotesRepositoryImplTest : public ::testing::Test {
   protected:
    std::shared_ptr<NotesRepositoryImpl> repository;
    std::shared_ptr<Db::Database> db;
    std::shared_ptr<Time::ClockMock> clock;

    void SetUp() override;

    void TearDown() override;

    int getNotesCount();

    int getLastRowId();
};