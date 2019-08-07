#pragma once

#include <algorithm>
#include <iostream>
#include <vector>
#include "note/notes_repository.hpp"

class InMemoryNoteRepository : public NotesRepository {
   private:
    std::vector<Note> notes;
    int currentId = 0;

   public:
    void insert(Draft note) override;

    void deleteWithId(int id) override;

    void update(int id, Draft note) override;

    std::vector<Note> getAll() override;
};