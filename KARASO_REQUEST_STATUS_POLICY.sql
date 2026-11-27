-- Allow each signed-in user to read only their own admin request status.
-- Owner policy from the main approval SQL remains in place.
DROP POLICY IF EXISTS user_read_own_admin_request ON public.staff_admin_requests;
CREATE POLICY user_read_own_admin_request
ON public.staff_admin_requests
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

GRANT SELECT ON public.staff_admin_requests TO authenticated;
