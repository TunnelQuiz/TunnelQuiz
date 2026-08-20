#!/usr/bin/env python3
"""Turn-Logging: Index-Zeile + Volltext-Archiv aus Cursor-Transcript (VPS-Cron-Sync)."""
from __future__ import annotations

import datetime
import glob
import json
import os
import re
import sys
from typing import Any

MAX_FIELD_BYTES = 512_000
DEFAULT_LOG_DIR = "/opt/Azubuilder/.cursor/logs/agent-turns"
DEFAULT_TRANSCRIPT_ROOTS = [
    "/home/jjl/.cursor/projects/opt-LauerTeam/agent-transcripts",
    "/home/jjl/.cursor/projects/opt-LauerTeam-Domains-myAgentsDomain/agent-transcripts",
    "/home/jjl/.cursor/projects/opt/agent-transcripts",
]
WORKSPACE_BY_CURSOR_PROJECT = {
    "opt-LauerTeam": "/opt/Azubuilder",
    "opt-LauerTeam-Domains-myAgentsDomain": "/opt/Azubuilder/Domains/myAgentsDomain",
    "opt": "/opt",
}
MONTH_NAMES = (
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december",
)
WEEKDAY_NAMES = (
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
)
SECRET_PATTERNS = [
    re.compile(r"(sk-[A-Za-z0-9_-]{20,})"),
    re.compile(r"(Bearer\s+[A-Za-z0-9._-]+)", re.I),
    re.compile(
        r"(?i)((?:api[_-]?key|secret|password|token|auth)\s*[=:]\s*)([^\s'\"]{8,})"
    ),
]
USER_QUERY_RE = re.compile(r"<user_query>\s*(.*?)\s*</user_query>", re.S | re.I)
ARCHIVE_PREFIX_RE = re.compile(r"^\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-")
SESSION_PREFIX_RE = re.compile(r"^(\d{4}-\d{2}-\d{2})-\d{2}-\d{2}-\d{2}-")
UUID_DIR_RE = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
    re.I,
)
CONVERSATION_ID_SUFFIX_RE = re.compile(
    r"([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$",
    re.I,
)


def redact(text: str) -> str:
    if not text:
        return text
    out = text
    out = SECRET_PATTERNS[0].sub("[REDACTED]", out)
    out = SECRET_PATTERNS[1].sub("Bearer [REDACTED]", out)

    def _mask(m: re.Match[str]) -> str:
        return f"{m.group(1)}[REDACTED]"

    out = SECRET_PATTERNS[2].sub(_mask, out)
    return out


def truncate(text: str, limit: int = MAX_FIELD_BYTES) -> tuple[str, bool]:
    encoded = text.encode("utf-8")
    if len(encoded) <= limit:
        return text, False
    return encoded[:limit].decode("utf-8", errors="ignore"), True


def message_text(record: dict[str, Any]) -> str:
    parts: list[str] = []
    for item in record.get("message", {}).get("content", []) or []:
        if item.get("type") == "text" and item.get("text"):
            parts.append(str(item["text"]))
    return "\n".join(parts)


def turn_slices(records: list[dict[str, Any]]) -> list[list[dict[str, Any]]]:
    """Split transcript into completed turns (each ending at turn_ended)."""
    turn_ended = [i for i, rec in enumerate(records) if rec.get("type") == "turn_ended"]
    slices: list[list[dict[str, Any]]] = []
    prev = -1
    for te in turn_ended:
        slices.append(records[prev + 1 : te])
        prev = te
    return slices


def turn_slice(records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Return records for the most recent turn."""
    slices = turn_slices(records)
    if not slices:
        return records

    turn_ended = [i for i, rec in enumerate(records) if rec.get("type") == "turn_ended"]
    if not turn_ended:
        return records

    last_te = turn_ended[-1]
    after = records[last_te + 1 :]
    if any(rec.get("role") in ("user", "assistant") for rec in after):
        return after

    return slices[-1]


def extract_from_slice(slice_records: list[dict[str, Any]]) -> dict[str, Any]:
    user_message = ""
    assistant_parts: list[str] = []
    tool_calls: list[dict[str, Any]] = []

    for rec in slice_records:
        role = rec.get("role")
        if role == "user":
            user_message = message_text(rec)
        elif role == "assistant":
            for item in rec.get("message", {}).get("content", []) or []:
                if item.get("type") == "text" and item.get("text"):
                    assistant_parts.append(str(item["text"]))
                elif item.get("type") == "tool_use":
                    tool_calls.append(
                        {
                            "name": item.get("name"),
                            "input": item.get("input"),
                        }
                    )

    return {
        "user_message": user_message,
        "assistant_message": "\n\n".join(assistant_parts),
        "tool_calls": tool_calls,
    }


def extract_last_turn(records: list[dict[str, Any]]) -> dict[str, Any]:
    return extract_from_slice(turn_slice(records))


def load_transcript(path: str) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            records.append(json.loads(line))
    return records


def enrich_payload(payload: dict[str, Any]) -> dict[str, Any]:
    out = dict(payload)
    if not out.get("transcript_path"):
        out["transcript_path"] = os.environ.get("CURSOR_TRANSCRIPT_PATH")
    if not out.get("cwd"):
        out["cwd"] = os.environ.get("CURSOR_PROJECT_DIR") or os.getcwd()
    if not out.get("workspace_roots"):
        project = os.environ.get("CURSOR_PROJECT_DIR")
        if project:
            out["workspace_roots"] = [project]
    if not out.get("conversation_id") and not out.get("session_id"):
        path = out.get("transcript_path") or ""
        parts = path.replace("\\", "/").rstrip("/").split("/")
        if len(parts) >= 2 and parts[-2]:
            out["conversation_id"] = parts[-2]
    if not out.get("cursor_version"):
        out["cursor_version"] = os.environ.get("CURSOR_VERSION")
    return out


def slug_keyword(user_message: str, max_len: int = 40) -> str:
    text = user_message or ""
    match = USER_QUERY_RE.search(text)
    if match:
        text = match.group(1)
    else:
        text = re.sub(r"<[^>]+>", " ", text)
    text = text.strip().split("\n")[0][:200]
    slug = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    if not slug:
        return "turn"
    return slug[:max_len].rstrip("-")


def safe_generation_id(generation_id: str) -> str:
    return re.sub(r"[^A-Za-z0-9._-]+", "-", generation_id).strip("-") or "unknown"


def archive_filename(
    when: datetime.datetime,
    keyword: str,
    generation_id: str,
) -> str:
    prefix = when.astimezone().strftime("%Y-%m-%d-%H-%M-%S")
    return f"{prefix}-{slug_keyword(keyword)}-{safe_generation_id(generation_id)}.json"


def date_bucket_for(when: datetime.datetime) -> str:
    local = when.astimezone()
    month = MONTH_NAMES[local.month - 1]
    weekday = WEEKDAY_NAMES[local.weekday()]
    return os.path.join(
        local.strftime("%Y"),
        f"{local.month:02d} {month}",
        f"{local.day:02d} {weekday}",
    )


def session_dir_name(
    when: datetime.datetime,
    keyword: str,
    conversation_id: str,
) -> str:
    prefix = when.astimezone().strftime("%Y-%m-%d-%H-%M-%S")
    return f"{prefix}-{slug_keyword(keyword)}-{conversation_id}"


def session_dir_relative(
    when: datetime.datetime,
    keyword: str,
    conversation_id: str,
) -> str:
    return f"{date_bucket_for(when)}/{session_dir_name(when, keyword, conversation_id)}"


def when_from_session_dir_name(name: str) -> datetime.datetime | None:
    match = re.match(r"^(\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2})-", name)
    if not match:
        return None
    try:
        parsed = datetime.datetime.strptime(match.group(1), "%Y-%m-%d-%H-%M-%S")
    except ValueError:
        return None
    return parsed.replace(tzinfo=datetime.datetime.now().astimezone().tzinfo)


def conversation_id_from_session_dir(name: str) -> str | None:
    match = CONVERSATION_ID_SUFFIX_RE.search(name)
    return match.group(1) if match else None


def session_dirs_map(state: dict[str, Any]) -> dict[str, str]:
    raw = state.setdefault("session_dirs", {})
    return raw if isinstance(raw, dict) else {}


def _join_archive_rel(archive_root: str, rel: str) -> str:
    return os.path.join(archive_root, rel.replace("/", os.sep))


def ensure_session_dir(
    log_dir: str,
    conversation_id: str,
    keyword: str,
    when: datetime.datetime,
    state: dict[str, Any] | None = None,
) -> str:
    archive_root = os.path.join(log_dir, "_archive")
    dirs = session_dirs_map(state) if state is not None else {}

    if conversation_id in dirs:
        path = _join_archive_rel(archive_root, dirs[conversation_id])
        if os.path.isdir(path):
            os.makedirs(path, exist_ok=True)
            return path

    rel = session_dir_relative(when, keyword, conversation_id)
    new_path = _join_archive_rel(archive_root, rel)
    dir_name = session_dir_name(when, keyword, conversation_id)
    legacy_paths = [
        os.path.join(archive_root, dir_name),
        os.path.join(archive_root, conversation_id),
    ]

    for legacy_path in legacy_paths:
        if os.path.isdir(legacy_path) and legacy_path != new_path:
            os.makedirs(os.path.dirname(new_path), exist_ok=True)
            if not os.path.exists(new_path):
                os.rename(legacy_path, new_path)
            break
    else:
        os.makedirs(new_path, exist_ok=True)

    if state is not None:
        dirs[conversation_id] = rel.replace("\\", "/")
    return new_path


def find_archive_dir(log_dir: str, conversation_id: str) -> str | None:
    archive_root = os.path.join(log_dir, "_archive")
    state_path = os.path.join(log_dir, "sync-state.json")
    if os.path.isfile(state_path):
        dirs = session_dirs_map(load_sync_state(state_path))
        mapped = dirs.get(conversation_id)
        if mapped:
            path = _join_archive_rel(archive_root, mapped)
            if os.path.isdir(path):
                return path
            flat = os.path.join(archive_root, os.path.basename(mapped))
            if os.path.isdir(flat):
                return flat

    for legacy in (
        os.path.join(archive_root, conversation_id),
        *_glob_session_dirs(archive_root, conversation_id),
    ):
        if os.path.isdir(legacy):
            return legacy
    return None


def _glob_session_dirs(archive_root: str, conversation_id: str) -> list[str]:
    pattern = os.path.join(archive_root, "**", f"*{conversation_id}")
    return sorted(
        path
        for path in glob.glob(pattern, recursive=True)
        if os.path.isdir(path) and os.path.basename(path).endswith(conversation_id)
    )


def find_existing_archive(log_dir: str, conversation_id: str, generation_id: str) -> str | None:
    archive_dir = find_archive_dir(log_dir, conversation_id)
    if not archive_dir:
        return None
    return _find_existing_archive_in_dir(archive_dir, generation_id)


def _find_existing_archive_in_dir(archive_dir: str, generation_id: str) -> str | None:
    if not os.path.isdir(archive_dir):
        return None
    safe_gen = safe_generation_id(generation_id)
    legacy = f"{generation_id}.json"
    suffix = f"-{safe_gen}.json"
    for name in os.listdir(archive_dir):
        if name == legacy or name.endswith(suffix):
            return os.path.join(archive_dir, name)
    return None


def write_debug(log_dir: str, line: dict[str, Any]) -> None:
    debug_dir = os.path.join(log_dir, "debug")
    os.makedirs(debug_dir, exist_ok=True)
    debug_path = os.path.join(
        debug_dir, datetime.datetime.now().astimezone().strftime("%Y-%m-%d") + ".jsonl"
    )
    with open(debug_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(line, ensure_ascii=False) + "\n")


def append_index(log_dir: str, entry: dict[str, Any]) -> None:
    os.makedirs(log_dir, exist_ok=True)
    index_path = os.path.join(
        log_dir, datetime.datetime.now().astimezone().strftime("%Y-%m-%d") + ".jsonl"
    )
    session = entry.get("session")
    generation = entry.get("generation")
    if session and generation and os.path.isfile(index_path):
        with open(index_path, encoding="utf-8") as f:
            for line in f:
                try:
                    existing = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if (
                    existing.get("session") == session
                    and existing.get("generation") == generation
                ):
                    return
    with open(index_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


def write_archive(
    *,
    agent: str,
    log_dir: str,
    now: datetime.datetime,
    conversation_id: str,
    generation_id: str,
    transcript_path: str,
    turn: dict[str, Any],
    event: str,
    status: str | None = None,
    workspace: str | None = None,
    model: str | None = None,
    cursor_version: str | None = None,
    loop_count: int | None = None,
    source: str = "hook",
    state: dict[str, Any] | None = None,
) -> dict[str, Any] | None:
    keyword = turn.get("user_message", "")
    archive_dir = ensure_session_dir(log_dir, conversation_id, keyword, now, state)
    basename = archive_filename(now, keyword, generation_id)
    archive_path = os.path.join(archive_dir, basename)

    existing_path = _find_existing_archive_in_dir(archive_dir, generation_id)
    if existing_path:
        try:
            with open(existing_path, encoding="utf-8") as f:
                existing = json.load(f)
            if existing.get("user_message") or existing.get("assistant_message"):
                return {"archive": existing_path, "skipped": True}
        except (OSError, json.JSONDecodeError):
            pass

    truncated: dict[str, bool] = {}
    for key in ("user_message", "assistant_message"):
        turn[key], was_truncated = truncate(redact(turn[key]))
        if was_truncated:
            truncated[key] = True

    entry: dict[str, Any] = {
        "ts": now.isoformat(timespec="seconds"),
        "agent": agent,
        "conversation_id": conversation_id,
        "generation_id": generation_id,
        "archive_dir": os.path.basename(archive_dir),
        "archive_file": basename,
        "event": event,
        "status": status,
        "workspace": workspace,
        "model": model,
        "loop_count": loop_count,
        "cursor_version": cursor_version,
        "user_message": turn["user_message"] or None,
        "assistant_message": turn["assistant_message"] or None,
        "tool_calls": turn["tool_calls"] or None,
        "transcript_source": transcript_path,
        "source": source,
    }
    if truncated:
        entry["truncated"] = truncated
    entry = {k: v for k, v in entry.items() if v is not None}

    os.makedirs(archive_dir, exist_ok=True)
    with open(archive_path, "w", encoding="utf-8") as f:
        json.dump(entry, f, ensure_ascii=False, indent=2)
        f.write("\n")

    return {"archive": archive_path}


def archive_turn(
    payload: dict[str, Any],
    agent: str,
    log_dir: str,
    now: datetime.datetime,
    source: str = "hook",
) -> dict[str, Any] | None:
    payload = enrich_payload(payload)
    transcript_path = payload.get("transcript_path")
    conversation_id = (
        payload.get("conversation_id")
        or payload.get("session_id")
        or "unknown"
    )
    generation_id = payload.get("generation_id") or now.strftime("%Y%m%dT%H%M%S")

    if not transcript_path or not os.path.isfile(transcript_path):
        return None

    try:
        turn = extract_last_turn(load_transcript(transcript_path))
    except (OSError, json.JSONDecodeError):
        return None

    return write_archive(
        agent=agent,
        log_dir=log_dir,
        now=now,
        conversation_id=conversation_id,
        generation_id=generation_id,
        transcript_path=transcript_path,
        turn=turn,
        event=payload.get("hook_event_name") or payload.get("event") or "stop",
        status=payload.get("status"),
        workspace=payload.get("cwd") or (payload.get("workspace_roots") or [None])[0],
        model=payload.get("model"),
        cursor_version=payload.get("cursor_version"),
        loop_count=payload.get("loop_count"),
        source=source,
    )


def transcript_roots_from_env() -> list[str]:
    multi = os.environ.get("AGENT_TRANSCRIPT_ROOTS", "").strip()
    if multi:
        return [root.strip() for root in multi.split(",") if root.strip()]
    single = os.environ.get("AGENT_TRANSCRIPT_ROOT", "").strip()
    if single:
        return [single]
    return list(DEFAULT_TRANSCRIPT_ROOTS)


def workspace_for_transcript(transcript_path: str, default: str) -> str:
    parts = transcript_path.replace("\\", "/").split("/")
    try:
        slug = parts[parts.index("projects") + 1]
    except (ValueError, IndexError):
        return default
    return WORKSPACE_BY_CURSOR_PROJECT.get(slug, default)


def load_sync_state(path: str) -> dict[str, Any]:
    if not os.path.isfile(path):
        return {"transcripts": {}}
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save_sync_state(path: str, state: dict[str, Any]) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)
        f.write("\n")


def sync_transcripts(
    log_dir: str,
    transcript_roots: list[str],
    default_workspace: str = "/opt/Azubuilder/Domains/myAgentsDomain",
) -> int:
    state_path = os.path.join(log_dir, "sync-state.json")
    state = load_sync_state(state_path)
    transcripts_state: dict[str, Any] = state.setdefault("transcripts", {})
    archived = 0

    transcript_paths: list[str] = []
    for transcript_root in transcript_roots:
        if not os.path.isdir(transcript_root):
            continue
        transcript_paths.extend(glob.glob(os.path.join(transcript_root, "*", "*.jsonl")))

    for transcript_path in sorted(set(transcript_paths)):
        workspace = workspace_for_transcript(transcript_path, default_workspace)
        try:
            records = load_transcript(transcript_path)
        except (OSError, json.JSONDecodeError):
            continue

        slices = turn_slices(records)
        if not slices:
            continue

        conversation_id = os.path.basename(os.path.dirname(transcript_path))
        done = int(transcripts_state.get(transcript_path, 0))

        first_keyword = ""
        session_when: datetime.datetime | None = None
        for slice_records in slices:
            turn = extract_from_slice(slice_records)
            if turn["user_message"]:
                first_keyword = turn["user_message"]
                session_when = datetime.datetime.fromtimestamp(
                    os.path.getmtime(transcript_path),
                    tz=datetime.datetime.now().astimezone().tzinfo,
                )
                break
        if first_keyword and session_when:
            ensure_session_dir(
                log_dir,
                conversation_id,
                first_keyword,
                session_when,
                state,
            )

        for idx in range(done, len(slices)):
            turn = extract_from_slice(slices[idx])
            if not turn["user_message"] and not turn["assistant_message"]:
                continue

            generation_id = f"sync-turn-{idx + 1:04d}"
            now = datetime.datetime.now().astimezone()
            info = write_archive(
                agent="cursor-sync",
                log_dir=log_dir,
                now=now,
                conversation_id=conversation_id,
                generation_id=generation_id,
                transcript_path=transcript_path,
                turn=turn,
                event="sync",
                status="completed",
                workspace=workspace,
                source="sync",
                state=state,
            )
            if not info:
                continue

            append_index(
                log_dir,
                {
                    "ts": now.isoformat(timespec="seconds"),
                    "agent": "cursor-sync",
                    "event": "sync",
                    "session": conversation_id,
                    "generation": generation_id,
                    "workspace": workspace,
                    "status": "completed",
                    "archive": info["archive"],
                },
            )
            archived += 1

        transcripts_state[transcript_path] = len(slices)

    save_sync_state(state_path, state)
    return archived


def main() -> int:
    agent = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("AGENT_NAME", "unknown")
    log_dir = (
        sys.argv[2]
        if len(sys.argv) > 2
        else os.environ.get("AGENT_TURNLOG_DIR", DEFAULT_LOG_DIR)
    )

    raw = os.environ.get("AGENT_HOOK_PAYLOAD") or sys.stdin.read()
    try:
        payload = json.loads(raw or "{}")
    except json.JSONDecodeError:
        payload = {}

    payload = enrich_payload(payload)
    now = datetime.datetime.now().astimezone()
    write_debug(
        log_dir,
        {
            "ts": now.isoformat(timespec="seconds"),
            "agent": agent,
            "event": payload.get("hook_event_name") or payload.get("event") or "unknown",
            "session": payload.get("session_id") or payload.get("conversation_id"),
            "generation": payload.get("generation_id"),
            "has_transcript": bool(payload.get("transcript_path")),
            "remote": os.environ.get("CURSOR_CODE_REMOTE"),
        },
    )

    archive_info = archive_turn(payload, agent, log_dir, now)

    entry: dict[str, Any] = {
        "ts": now.isoformat(timespec="seconds"),
        "agent": agent,
        "event": payload.get("hook_event_name") or payload.get("event") or "turn-end",
        "session": payload.get("session_id") or payload.get("conversation_id"),
        "generation": payload.get("generation_id"),
        "workspace": payload.get("cwd")
        or (payload.get("workspace_roots") or [None])[0]
        or os.getcwd(),
        "model": payload.get("model"),
        "status": payload.get("status"),
    }
    if archive_info and archive_info.get("archive"):
        entry["archive"] = archive_info["archive"]
    elif not payload.get("transcript_path"):
        entry["archive_error"] = "no_transcript_path"
    elif not archive_info:
        entry["archive_error"] = "archive_failed"

    entry = {k: v for k, v in entry.items() if v is not None}
    append_index(log_dir, entry)
    return 0


def sync_main() -> int:
    log_dir = os.environ.get("AGENT_TURNLOG_DIR", DEFAULT_LOG_DIR)
    default_workspace = os.environ.get("AGENT_WORKSPACE", "/opt/Azubuilder/Domains/myAgentsDomain")
    count = sync_transcripts(log_dir, transcript_roots_from_env(), default_workspace)
    if count:
        write_debug(
            log_dir,
            {
                "ts": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
                "agent": "cursor-sync",
                "event": "sync-run",
                "archived": count,
            },
        )
    return 0


def rename_archives(log_dir: str) -> int:
    renamed = 0
    pattern = os.path.join(log_dir, "_archive", "**", "*.json")
    for path in sorted(glob.glob(pattern, recursive=True)):
        name = os.path.basename(path)
        if ARCHIVE_PREFIX_RE.match(name):
            continue
        try:
            with open(path, encoding="utf-8") as f:
                data = json.load(f)
        except (OSError, json.JSONDecodeError):
            continue
        generation_id = data.get("generation_id") or "unknown"
        archive_dir = os.path.dirname(path)
        if _find_existing_archive_in_dir(archive_dir, generation_id) != path:
            continue
        ts_raw = data.get("ts")
        try:
            when = datetime.datetime.fromisoformat(ts_raw) if ts_raw else datetime.datetime.now().astimezone()
        except ValueError:
            when = datetime.datetime.now().astimezone()
        keyword = data.get("user_message") or ""
        new_name = archive_filename(when, keyword, generation_id)
        new_path = os.path.join(archive_dir, new_name)
        if new_path == path:
            continue
        if os.path.exists(new_path):
            continue
        os.rename(path, new_path)
        data["archive_file"] = new_name
        data["archive_dir"] = os.path.basename(archive_dir)
        with open(new_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
        renamed += 1
    return renamed


def _is_month_bucket(part: str) -> bool:
    if len(part) == 2 and part.isdigit():
        return True
    return bool(re.match(r"^\d{2} [a-z]+$", part))


def _is_day_bucket(part: str) -> bool:
    if part.endswith(" Day") and part[:-4].isdigit():
        return True
    return bool(re.match(r"^\d{2} [a-z]+$", part))


def is_date_bucket_session_path(path: str, archive_root: str) -> bool:
    rel = os.path.relpath(path, archive_root).replace("\\", "/")
    parts = rel.split("/")
    if len(parts) < 4:
        return False
    return (
        len(parts[0]) == 4
        and parts[0].isdigit()
        and _is_month_bucket(parts[1])
        and _is_day_bucket(parts[2])
    )


def when_from_archive_filename(name: str) -> datetime.datetime | None:
    return when_from_session_dir_name(name)


def earliest_when_in_session_dir(session_path: str) -> tuple[datetime.datetime | None, str]:
    earliest_when: datetime.datetime | None = None
    first_keyword = ""
    for json_path in sorted(glob.glob(os.path.join(session_path, "*.json"))):
        name = os.path.basename(json_path)
        when = when_from_archive_filename(name)
        if when is None:
            try:
                with open(json_path, encoding="utf-8") as f:
                    data = json.load(f)
            except (OSError, json.JSONDecodeError):
                continue
            ts_raw = data.get("ts")
            try:
                when = (
                    datetime.datetime.fromisoformat(ts_raw)
                    if ts_raw
                    else None
                )
            except ValueError:
                when = None
            if not first_keyword and data.get("user_message"):
                first_keyword = data["user_message"]
        else:
            try:
                with open(json_path, encoding="utf-8") as f:
                    data = json.load(f)
                if not first_keyword and data.get("user_message"):
                    first_keyword = data["user_message"]
            except (OSError, json.JSONDecodeError):
                pass
        if when and (earliest_when is None or when < earliest_when):
            earliest_when = when
    return earliest_when, first_keyword


def migrate_date_buckets(log_dir: str) -> int:
    archive_root = os.path.join(log_dir, "_archive")
    if not os.path.isdir(archive_root):
        return 0

    state_path = os.path.join(log_dir, "sync-state.json")
    state = load_sync_state(state_path)
    dirs_map = session_dirs_map(state)
    moved = 0

    session_dirs = sorted(
        {
            os.path.dirname(path)
            for path in glob.glob(os.path.join(archive_root, "**", "*.json"), recursive=True)
        }
    )

    for legacy_path in session_dirs:
        if is_date_bucket_session_path(legacy_path, archive_root):
            name = os.path.basename(legacy_path)
            conversation_id = conversation_id_from_session_dir(name) or (
                name if UUID_DIR_RE.match(name) else None
            )
            if conversation_id:
                earliest_when, first_keyword = earliest_when_in_session_dir(legacy_path)
                if earliest_when:
                    correct_rel = session_dir_relative(
                        earliest_when, first_keyword, conversation_id
                    ).replace("\\", "/")
                    correct_path = _join_archive_rel(archive_root, correct_rel)
                    if os.path.normpath(legacy_path) != os.path.normpath(correct_path):
                        if not os.path.exists(correct_path):
                            os.makedirs(os.path.dirname(correct_path), exist_ok=True)
                            os.rename(legacy_path, correct_path)
                            dirs_map[conversation_id] = correct_rel
                            moved += 1
                            continue
                rel = os.path.relpath(legacy_path, archive_root).replace("\\", "/")
                dirs_map[conversation_id] = rel
            continue

        name = os.path.basename(legacy_path)
        conversation_id = conversation_id_from_session_dir(name) or (
            name if UUID_DIR_RE.match(name) else None
        )
        if not conversation_id:
            continue

        when, first_keyword = earliest_when_in_session_dir(legacy_path)
        if when is None:
            when = datetime.datetime.now().astimezone()

        rel = session_dir_relative(when, first_keyword, conversation_id).replace("\\", "/")
        new_path = _join_archive_rel(archive_root, rel)
        if os.path.normpath(legacy_path) == os.path.normpath(new_path):
            dirs_map[conversation_id] = rel
            continue
        if os.path.exists(new_path):
            continue

        os.makedirs(os.path.dirname(new_path), exist_ok=True)
        os.rename(legacy_path, new_path)
        dirs_map[conversation_id] = rel
        moved += 1

    save_sync_state(state_path, state)
    return moved


def rename_archive_dirs(log_dir: str) -> int:
    archive_root = os.path.join(log_dir, "_archive")
    if not os.path.isdir(archive_root):
        return 0

    state_path = os.path.join(log_dir, "sync-state.json")
    state = load_sync_state(state_path)
    dirs = session_dirs_map(state)
    renamed = 0

    for name in sorted(os.listdir(archive_root)):
        if not UUID_DIR_RE.match(name):
            continue
        legacy_path = os.path.join(archive_root, name)
        if not os.path.isdir(legacy_path):
            continue

        conversation_id = name
        earliest_when: datetime.datetime | None = None
        first_keyword = ""
        for path in sorted(glob.glob(os.path.join(legacy_path, "*.json"))):
            try:
                with open(path, encoding="utf-8") as f:
                    data = json.load(f)
            except (OSError, json.JSONDecodeError):
                continue
            ts_raw = data.get("ts")
            try:
                when = (
                    datetime.datetime.fromisoformat(ts_raw)
                    if ts_raw
                    else datetime.datetime.now().astimezone()
                )
            except ValueError:
                when = datetime.datetime.now().astimezone()
            if earliest_when is None or when < earliest_when:
                earliest_when = when
            if not first_keyword and data.get("user_message"):
                first_keyword = data["user_message"]

        when = earliest_when or datetime.datetime.now().astimezone()
        new_path = ensure_session_dir(log_dir, conversation_id, first_keyword, when, state)
        if new_path != legacy_path:
            renamed += 1

    save_sync_state(state_path, state)
    return renamed


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--sync":
        sys.exit(sync_main())
    if len(sys.argv) > 1 and sys.argv[1] == "--migrate-date-buckets":
        log_dir = os.environ.get("AGENT_TURNLOG_DIR", DEFAULT_LOG_DIR)
        count = migrate_date_buckets(log_dir)
        print(f"migrated {count} session dirs")
        sys.exit(0)
    if len(sys.argv) > 1 and sys.argv[1] == "--rename-archives":
        log_dir = os.environ.get("AGENT_TURNLOG_DIR", DEFAULT_LOG_DIR)
        sys.exit(0 if rename_archives(log_dir) >= 0 else 1)
    if len(sys.argv) > 1 and sys.argv[1] == "--rename-archive-dirs":
        log_dir = os.environ.get("AGENT_TURNLOG_DIR", DEFAULT_LOG_DIR)
        sys.exit(0 if rename_archive_dirs(log_dir) >= 0 else 1)
    sys.exit(main())
