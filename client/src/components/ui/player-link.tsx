import React from 'react';
import { Link } from 'wouter';

type PlayerLinkProps = {
  playerName: string;
  className?: string;
  children?: React.ReactNode;
};

/**
 * PlayerLink - A component that makes player names clickable and navigate to their bio page
 * 
 * @param playerName - The name of the player (used to form the URL)
 * @param className - Optional CSS class names
 * @param children - Optional children (defaults to the player name)
 */
export function PlayerLink({ playerName, className = "", children }: PlayerLinkProps) {
  // Format the player name for the URL (lowercase, replace spaces with hyphens)
  const formattedName = playerName.toLowerCase().replace(/\s+/g, '-');
  const url = `/players/${formattedName}`;
  
  return (
    <Link href={url}>
      <a className={`cursor-pointer text-primary hover:underline ${className}`}>
        {children || playerName}
      </a>
    </Link>
  );
}

export default PlayerLink;