import { QueryClient } from "@tanstack/react-query";
import { createRouter } from "@tanstack/react-router";
import { routeTree } from "./routeTree.gen";

export const getRouter = () => {
  const queryClient = new QueryClient();

  const router = createRouter({
    routeTree,
    context: { queryClient },
    scrollRestoration: true,
    defaultPreloadStaleTime: 0,
    // Show the next screen as soon as it is ready. A slow screen shows its
    // loading state quickly instead of leaving the previous screen in place.
    defaultPendingMs: 0,
    defaultPendingMinMs: 0,
  });

  return router;
};
