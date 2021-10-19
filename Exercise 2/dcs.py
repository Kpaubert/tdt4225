from dataclasses import dataclass
import datetime


"""Dataclasses"""


@dataclass
class User:
    id: int
    has_labels: bool


@dataclass
class Activity:
    id: int
    user_id: int
    transportations_mode: str
    start_date_time: datetime
    end_date_time: datetime


@dataclass
class TrackPoint:
    id: int
    activity_id: int
    lat: float
    lon: float
    altitude: int
    date_days: float
    date_time: datetime
