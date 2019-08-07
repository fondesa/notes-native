#include "notes_repository_impl.hpp"
#include "database_cursor.hpp"

NotesRepositoryImpl::NotesRepositoryImpl(std::shared_ptr<Db::Database> db) : db(std::move(db)) {}

void NotesRepositoryImpl::insert(Draft draftNote) {
    auto movedDraftNote = std::move(draftNote);
    auto stmt = db->createStatement("INSERT INTO notes (title, description) "
                                    "VALUES (?, ?)");
    stmt->bind(1, movedDraftNote.getTitle());
    stmt->bind(2, movedDraftNote.getDescription());
    stmt->execute<void>();
}

void NotesRepositoryImpl::deleteWithId(int id) {
    auto stmt = db->createStatement("DELETE FROM notes "
                                    "WHERE rowid = ?");
    stmt->bind(1, id);
    stmt->execute<void>();
}

void NotesRepositoryImpl::update(int id, Draft draftNote) {
    auto stmt = db->createStatement("UPDATE notes "
                                    "SET title = ?, description = ? "
                                    "WHERE rowid = ?");
    stmt->bind(1, draftNote.getTitle());
    stmt->bind(2, draftNote.getDescription());
    stmt->bind(3, id);
    stmt->execute<void>();
}

void NotesRepositoryImpl::deleteAll() {
    auto stmt = db->createStatement("DELETE FROM notes");
    stmt->execute<void>();
}

std::vector<Note> NotesRepositoryImpl::getAll() {
    std::vector<Note> notes;
    auto selectStmt = db->createStatement("SELECT rowid, title, description FROM notes");
    auto cursor = selectStmt->execute<std::shared_ptr<Db::Cursor>>();
    while (cursor->next()) {
        auto id = cursor->get<int>(0);
        auto title = cursor->get<std::string>(1);
        auto description = cursor->get<std::string>(2);
        notes.emplace_back(id, title, description);
    }
    return notes;
}