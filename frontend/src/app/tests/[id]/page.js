import { redirect } from 'next/navigation';

export default async function TestRedirectPage({ params }) {
  const unwrappedParams = await params;
  const id = unwrappedParams.id;
  redirect(`/tests?mode=part&testId=${id}`);
}

