<?php

namespace App\Http\Controllers;

use App\Http\Requests\EventRequest;
use App\Http\Resources\EventResource;
use App\Models\Event;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Http\Request;

class EventController
{
    use AuthorizesRequests;
    public function index(Request $request)
    {
        try {
            $query = Event::forUser(auth()->id())->orderBy('start_date');

            if ($request->has(['start_date', 'end_date'])) {
                $query->betweenDates($request->start_date, $request->end_date);
            }

            return EventResource::collection($query->get());
        } catch (\Exception $e) {
            return response()->json(['error' => 'Failed to retrieve events'], 500);
        }
    }

    public function store(EventRequest $request): JsonResource|JsonResponse
    {
        try {
            $event = Event::create([
                ...$request->validated(),
                'user_id' => auth()->id(),
            ]);

            return new EventResource($event);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Failed to create event'], 500);
        }
    }

    public function show(Event $event)
    {
        try {
            $this->authorize('view', $event);
            return new EventResource($event);
        } catch (\Illuminate\Auth\Access\AuthorizationException $e) {
            return response()->json(['error' => 'Unauthorized'], 403);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Failed to retrieve event'], 500);
        }
    }

    public function update(EventRequest $request, Event $event): JsonResource|JsonResponse
    {
        try {
            $this->authorize('update', $event);
            $event->update($request->validated());
            return new EventResource($event);
        } catch (\Illuminate\Auth\Access\AuthorizationException $e) {
            return response()->json(['error' => 'Unauthorized'], 403);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Failed to update event'], 500);
        }
    }

    public function destroy(Event $event): JsonResponse
    {
        try {
            $this->authorize('delete', $event);
            $event->delete();
            return response()->json(['message' => 'Event deleted successfully']);
        } catch (\Illuminate\Auth\Access\AuthorizationException $e) {
            return response()->json(['error' => 'Unauthorized'], 403);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Failed to delete event'], 500);
        }
    }

    public function getEventsByDay(string $date)
    {
        try {
            $startOfDay = $date . ' 00:00:00';
            $endOfDay = $date . ' 23:59:59';
            
            $events = Event::forUser(auth()->id())
                ->where(function ($query) use ($startOfDay, $endOfDay) {
                    $query->whereBetween('start_date', [$startOfDay, $endOfDay])
                          ->orWhereBetween('end_date', [$startOfDay, $endOfDay])
                          ->orWhere(function ($q) use ($startOfDay, $endOfDay) {
                              $q->where('start_date', '<=', $startOfDay)
                                ->where('end_date', '>=', $endOfDay);
                          });
                })
                ->orderBy('start_date')
                ->get();
                
            return EventResource::collection($events);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Failed to retrieve events for day'], 500);
        }
    }
}