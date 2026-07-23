import { useRef, useCallback, useEffect } from "react";

/**
 * useDraggable — makes a modal/popup movable via its header.
 *
 * Smooth, 60fps, clamped 2D drag hook without layout thrashing or jitter.
 */
export function useDraggable() {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const handleRef    = useRef<HTMLElement | null>(null);

  const startPos  = useRef({ x: 0, y: 0 });
  const offset    = useRef({ x: 0, y: 0 });
  const bounds    = useRef({ minX: 0, maxX: 0, minY: 0, maxY: 0 });
  const dragging  = useRef(false);
  const rafId     = useRef<number | null>(null);

  const currentPos = useRef({ x: 0, y: 0 });

  const updatePosition = useCallback(() => {
    if (!containerRef.current) return;
    const { x, y } = currentPos.current;
    containerRef.current.style.transform = `translate3d(${x}px, ${y}px, 0px)`;
  }, []);

  const onMouseMove = useCallback((e: MouseEvent) => {
    if (!dragging.current) return;
    const dx = e.clientX - startPos.current.x;
    const dy = e.clientY - startPos.current.y;

    const rawX = offset.current.x + dx;
    const rawY = offset.current.y + dy;

    const clampedX = Math.min(Math.max(rawX, bounds.current.minX), bounds.current.maxX);
    const clampedY = Math.min(Math.max(rawY, bounds.current.minY), bounds.current.maxY);

    currentPos.current = { x: clampedX, y: clampedY };

    if (rafId.current === null) {
      rafId.current = requestAnimationFrame(() => {
        updatePosition();
        rafId.current = null;
      });
    }
  }, [updatePosition]);

  const onMouseUp = useCallback(() => {
    if (!dragging.current) return;
    dragging.current = false;

    // Save final position as the new baseline offset
    offset.current = { ...currentPos.current };

    // Restore text selection & cursors
    document.body.style.userSelect = "";
    document.body.style.cursor = "";
    if (handleRef.current) {
      handleRef.current.style.cursor = "grab";
    }

    if (rafId.current !== null) {
      cancelAnimationFrame(rafId.current);
      rafId.current = null;
    }

    window.removeEventListener("mousemove", onMouseMove);
    window.removeEventListener("mouseup",   onMouseUp);
  }, [onMouseMove]);

  const onMouseDown = useCallback((e: MouseEvent) => {
    // Only primary mouse button (left click)
    if (e.button !== 0) return;

    // Ignore clicks on interactive controls inside header (buttons, inputs, links, etc.)
    const target = e.target as HTMLElement;
    if (target.closest("button, input, select, textarea, a, svg, [role='button']")) return;

    const el = containerRef.current;
    if (!el) return;

    dragging.current = true;
    startPos.current = { x: e.clientX, y: e.clientY };

    // Compute layout bounds ONCE at drag start to avoid jitter/thrashing
    const rect = el.getBoundingClientRect();
    const vw   = window.innerWidth;
    const vh   = window.innerHeight;

    // Current position of element without current drag offset
    const initialLeft = rect.left - offset.current.x;
    const initialTop  = rect.top  - offset.current.y;

    bounds.current = {
      minX: -initialLeft + 20,
      maxX: vw - initialLeft - rect.width + (rect.width - 80),
      minY: -initialTop + 10,
      maxY: vh - initialTop - 50,
    };

    // Lock text selection & mouse cursor globally while dragging
    document.body.style.userSelect = "none";
    document.body.style.cursor = "grabbing";
    if (handleRef.current) {
      handleRef.current.style.cursor = "grabbing";
    }

    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("mouseup",   onMouseUp);
  }, [onMouseMove, onMouseUp]);

  useEffect(() => {
    const handle = handleRef.current;
    if (!handle) return;
    handle.style.cursor = "grab";
    handle.addEventListener("mousedown", onMouseDown);
    return () => {
      handle.removeEventListener("mousedown", onMouseDown);
      window.removeEventListener("mousemove", onMouseMove);
      window.removeEventListener("mouseup",   onMouseUp);
    };
  }, [onMouseDown, onMouseMove, onMouseUp]);

  // Reset position when the hook mounts fresh
  useEffect(() => {
    if (containerRef.current) {
      containerRef.current.style.transform = "";
      offset.current = { x: 0, y: 0 };
      currentPos.current = { x: 0, y: 0 };
    }
  }, []);

  return { containerRef, handleRef };
}
