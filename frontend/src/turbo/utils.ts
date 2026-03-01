import { TurboGlobalEventHandlersEventMap } from '@hotwired/turbo';

type TurboEvent = keyof TurboGlobalEventHandlersEventMap;

// Compile-time guard: TypeScript errors if any TurboEvent key is absent from the array
function allTurboEvents<T extends readonly TurboEvent[]>(
  events:T & ([TurboEvent] extends [T[number]] ? unknown : never),
):readonly TurboEvent[] {
  return events;
}

export function getTurboEvents():readonly TurboEvent[] {
  return allTurboEvents([
    'turbo:before-cache',
    'turbo:before-fetch-request',
    'turbo:before-fetch-response',
    'turbo:before-frame-morph',
    'turbo:before-frame-render',
    'turbo:before-morph-attribute',
    'turbo:before-morph-element',
    'turbo:before-prefetch',
    'turbo:before-render',
    'turbo:before-stream-render',
    'turbo:before-visit',
    'turbo:click',
    'turbo:fetch-request-error',
    'turbo:frame-load',
    'turbo:frame-missing',
    'turbo:frame-render',
    'turbo:load',
    'turbo:morph-element',
    'turbo:morph',
    'turbo:reload',
    'turbo:render',
    'turbo:submit-end',
    'turbo:submit-start',
    'turbo:visit',
  ] as const);
}
